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
import com.tonnysunm.contacts.databinding.FragmentSearchBinding
import com.tonnysunm.contacts.library.AndroidViewModelFactory
import com.tonnysunm.contacts.library.RecyclerAdapter
import com.tonnysunm.contacts.library.RecyclerItem
import com.tonnysunm.contacts.room.UserInSearch

class SearchFragment : Fragment() {

    private val searchSharedViewModel by lazy {
        ViewModelProvider(requireParentFragment()).get(SearchSharedViewModel::class.java)
    }

    private val viewModel by viewModels<SearchViewModel> {
        AndroidViewModelFactory(
            requireActivity().application,
            searchSharedViewModel,
            requireNotNull(arguments)
        )
    }

    private val adapter by lazy {
        RecyclerAdapter(
            RecyclerItem.diffCallback<UserInSearch>(), R.layout.list_item_user_placeholder
        ) { _, _, item ->
            val action = SearchPagerFragmentDirections.actionNavSearchToNavDetail(item.uniqueId)
            findNavController().navigate(action)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val fragment = this

        val binding = FragmentSearchBinding.inflate(
            inflater,
            container,
            false
        ).apply {
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
