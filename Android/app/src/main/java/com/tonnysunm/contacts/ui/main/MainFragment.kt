package com.tonnysunm.contacts.ui.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.paging.PagedList
import com.tonnysunm.contacts.databinding.MainFragmentBinding
import com.tonnysunm.contacts.library.AndroidViewModelFactory
import com.tonnysunm.contacts.library.NetworkState
import com.tonnysunm.contacts.library.RecyclerAdapter
import com.tonnysunm.contacts.library.RecyclerItem
import com.tonnysunm.contacts.room.User
import timber.log.Timber

//TODO: add networking state machine and initial state machine

class MainFragment : Fragment() {

    companion object {
        fun newInstance() = MainFragment()
    }

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

        val adapter = RecyclerAdapter(RecyclerItem.diffCallback<User>()) {

        }.apply {
            this.setHasStableIds(true)
        }

        val binding = MainFragmentBinding.inflate(inflater, container, false).apply {
            lifecycleOwner = fragment
            viewModel = fragment.viewModel

            recyclerView.adapter = adapter
        }

        val listing = viewModel.getListing()
        listing.pagedList.observe(this.viewLifecycleOwner, Observer {
//            showEmptyList(it?.size == 0)

            Timber.d("1")
            _temp = it
        })

        listing.refreshState.observe(this.viewLifecycleOwner, Observer {
            binding.refresher.isRefreshing = it == NetworkState.LOADING

            Timber.d("2 ${it == NetworkState.LOADING}")

            if (it == NetworkState.LOADED) {
                Timber.d("2")

                adapter.submitList(_temp)
            }
        })

        listing.networkState.observe(this.viewLifecycleOwner, Observer {


        })

        binding.refresher.setOnRefreshListener {
            listing.refresh()
        }

        return binding.root
    }

}
