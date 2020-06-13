package com.tonnysunm.contacts.ui.search

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.tonnysunm.contacts.R
import com.tonnysunm.contacts.databinding.SearchFragmentBinding
import com.tonnysunm.contacts.library.AndroidViewModelFactory
import com.tonnysunm.contacts.library.RecyclerAdapter
import com.tonnysunm.contacts.library.RecyclerItem
import com.tonnysunm.contacts.room.User

class SearchFragment : Fragment() {

    private val searchSharedViewModel by lazy {
        val activity = requireActivity() as SearchActivity
        ViewModelProvider(activity).get(SearchSharedViewModel::class.java)
    }

    private val viewModel by viewModels<SearchViewModel> {
        val activity = requireActivity() as SearchActivity
        AndroidViewModelFactory(activity.application, searchSharedViewModel, arguments)
    }

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
                val action = SearchFragmentDirections.actionNavSearchToNavDetail(item.id)
                fragment.findNavController().navigate(action)
            }

        val binding = SearchFragmentBinding.inflate(inflater, container, false).apply {
            lifecycleOwner = fragment
            viewModel = fragment.viewModel

            recyclerView.adapter = adapter
        }

        viewModel.pageList.observe(this.viewLifecycleOwner, Observer {
            adapter.submitList(it)
        })

        return binding.root
    }

    companion object {
        const val ARG_FILTER_VALUE = "filter_value"

        fun newInstance(filterValue: Int) = SearchFragment().apply {
            arguments = Bundle().apply {
                putInt(ARG_FILTER_VALUE, filterValue)
            }
        }
    }
}
