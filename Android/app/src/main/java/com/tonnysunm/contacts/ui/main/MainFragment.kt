package com.tonnysunm.contacts.ui.main

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.ImageView
import android.widget.TextView
import androidx.core.view.isGone
import androidx.databinding.BindingAdapter
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.tonnysunm.contacts.GlideApp
import com.tonnysunm.contacts.R
import com.tonnysunm.contacts.databinding.MainFragmentBinding
import com.tonnysunm.contacts.library.AndroidViewModelFactory
import com.tonnysunm.contacts.library.RecyclerAdapter
import com.tonnysunm.contacts.library.diffCallback
import com.tonnysunm.contacts.model.User
import timber.log.Timber

class MainFragment : Fragment() {

    val seed = "contacts"

    companion object {
        fun newInstance() = MainFragment()
    }

    val viewModel by viewModels<MainViewModel> {
        AndroidViewModelFactory(requireActivity().application, seed)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val fragment = this

        val adapter =
            RecyclerAdapter(User::class.java.diffCallback()) {
            }

        val binding = MainFragmentBinding.inflate(inflater, container, false).apply {
            lifecycleOwner = fragment
            viewModel = fragment.viewModel

            recyclerView.adapter = adapter
        }

        viewModel.data.observe(this.viewLifecycleOwner, Observer {
            Log.d("i", it.toString())
            adapter.submitList(it)
        })

        return binding.root
    }

}

@BindingAdapter("imageUrl")
fun loadImage(view: ImageView, url: String?) {
    if (view.isGone || url == null) return

    if (!view.clipToOutline) {
        view.clipToOutline =  true
    }

    GlideApp.with(view.context)
        .load(url)
        .into(view)
}
