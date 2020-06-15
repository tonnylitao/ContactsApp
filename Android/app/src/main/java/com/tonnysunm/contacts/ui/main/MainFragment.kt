package com.tonnysunm.contacts.ui.main

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
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
import com.tonnysunm.contacts.room.UserInHome
import kotlinx.android.synthetic.main.fragment_detail.*


class MainFragment : Fragment(R.layout.fragment_main) {

    private val viewModel by viewModels<MainViewModel> {
        AndroidViewModelFactory(requireActivity().application)
    }

    private val listing by lazy {
        viewModel.getPageKeyedListing()
    }

    private val adapter by lazy {
        RecyclerAdapter(
            RecyclerItem.diffCallback<UserInHome>(),
            R.layout.list_item_user_placeholder
        ) { _, _, item ->

            val action = MainFragmentDirections.actionNavMainToNavDetail(item.uniqueId)
            findNavController().navigate(action)
        }
    }

    private var _temp: PagedList<UserUIModel>? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        /**
         * setup toolbar
         */
        val navController = findNavController()
        val appBarConfiguration = AppBarConfiguration(navController.graph)
        toolbar.setupWithNavController(navController, appBarConfiguration)

        toolbar.setOnMenuItemClickListener {
            val nav = findNavController()
            it.onNavDestinationSelected(nav)
        }

        /**
         * setup observers
         */
        val fragment = this

        val binding = FragmentMainBinding.bind(view).apply {
            lifecycleOwner = fragment
            viewModel = fragment.viewModel

            recyclerView.adapter = adapter
        }

        listing.pagedList.observe(this.viewLifecycleOwner, Observer {
            /**
             * submitList to adapter after data source initialization
             * a trick to avoid white screen (lack of data)
             */
            _temp = it
        })

        listing.initialState.observe(this.viewLifecycleOwner, Observer {
            binding.refresher.isRefreshing = it == State.Loading

            if (it is State.Success) {
                binding.shimmer.stopShimmer()
                binding.shimmer.isVisible = false

                adapter.submitList(_temp)

                if (it.source == Source.LOCAL) {
                    Snackbar.make(requireView(), "📴 OFFLINE", Snackbar.LENGTH_SHORT).show()
                }
            }
        })

        listing.networkState.observe(this.viewLifecycleOwner, Observer { state ->

            if (state is State.Error) {
                val message = state.message ?: return@Observer

                Snackbar.make(
                    this.requireView(),
                    "💀Using Cached Data, $message",
                    Snackbar.LENGTH_SHORT
                ).show()
            }
        })

        binding.refresher.setOnRefreshListener {
            listing.refresh?.invoke()
        }
    }
}
