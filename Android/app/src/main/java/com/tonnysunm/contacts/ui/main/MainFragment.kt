package com.tonnysunm.contacts.ui.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.tonnysunm.contacts.databinding.MainFragmentBinding
import com.tonnysunm.contacts.library.AndroidViewModelFactory
import com.tonnysunm.contacts.library.RecyclerAdapter
import com.tonnysunm.contacts.library.RecyclerItem
import com.tonnysunm.contacts.room.User

class MainFragment : Fragment() {

    companion object {
        fun newInstance() = MainFragment()
    }

    private val seed = "contacts"

    private val viewModel by viewModels<MainViewModel> {
        AndroidViewModelFactory(requireActivity().application, seed)
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        val fragment = this

        val adapter = RecyclerAdapter(RecyclerItem.diffCallback<User>()) {
        }

        val binding = MainFragmentBinding.inflate(inflater, container, false).apply {
            lifecycleOwner = fragment
            viewModel = fragment.viewModel

            recyclerView.adapter = adapter
        }

        viewModel.data.observe(this.viewLifecycleOwner, Observer {
            adapter.submitList(it)
        })

        return binding.root
    }

}
