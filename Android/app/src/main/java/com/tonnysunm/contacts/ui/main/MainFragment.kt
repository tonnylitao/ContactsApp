package com.tonnysunm.contacts.ui.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.onNavDestinationSelected
import androidx.navigation.ui.setupWithNavController
import androidx.paging.PagedList
import com.google.android.material.snackbar.Snackbar
import com.tonnysunm.contacts.R
import com.tonnysunm.contacts.databinding.FragmentMainBinding
import com.tonnysunm.contacts.library.*
import com.tonnysunm.contacts.room.User
import kotlinx.android.synthetic.main.fragment_main.*
import timber.log.Timber


class MainFragment : Fragment() {

    private val viewModel by viewModels<MainViewModel> {
        AndroidViewModelFactory(requireActivity().application)
    }

    private var _temp: PagedList<User>? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val fragment = this

        val adapter =
            RecyclerAdapter(
                RecyclerItem.diffCallback<User>(),
                R.layout.list_item_user_placeholder
            ) { _, _, item ->
                val action = MainFragmentDirections.actionNavMainToNavDetail(item.id)
                fragment.findNavController().navigate(action)
            }

        val binding = FragmentMainBinding.inflate(inflater, container, false).apply {
            lifecycleOwner = fragment
            viewModel = fragment.viewModel

            recyclerView.adapter = adapter
        }

        val listing = viewModel.getPageKeyedListing()
        listing.pagedList.observe(this.viewLifecycleOwner, Observer {
//            updateEmptyTips(it?.size == 0)
            /**
             * submitList to adapter after data source initialization
             * to avoid white screen (lack of data)
             */
            _temp = it
        })

        listing.initialState.observe(this.viewLifecycleOwner, Observer {
            binding.refresher.isRefreshing = it == State.Loading

            if (it is State.Success) {
                binding.shimmer.stopShimmer()
                binding.shimmer.visibility = View.GONE
                adapter.submitList(_temp)

                Snackbar.make(this.requireView(), it.source.tips(), Snackbar.LENGTH_SHORT)
                    .show();
            }
        })

        listing.networkState.observe(this.viewLifecycleOwner, Observer { state ->
            Timber.d(state.toString())

            if (state is State.Error) {
                val message = state.message ?: return@Observer

                Snackbar.make(
                    this.requireView(),
                    "💀Using Cached Data, $message",
                    Snackbar.LENGTH_LONG
                ).show();
            }
        })

        binding.refresher.setOnRefreshListener {
            listing.refresh?.invoke()
        }

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val navController = findNavController()
        val appBarConfiguration = AppBarConfiguration(navController.graph)
        toolbar.setupWithNavController(navController, appBarConfiguration)

        toolbar.setOnMenuItemClickListener {
            val nav = findNavController()
            it.onNavDestinationSelected(nav)
        }
    }
}
