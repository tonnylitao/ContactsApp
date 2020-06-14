package com.tonnysunm.contacts.ui.detail

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.setupWithNavController
import com.tonnysunm.contacts.R
import com.tonnysunm.contacts.databinding.FragmentDetailBinding
import com.tonnysunm.contacts.library.AndroidViewModelFactory
import kotlinx.android.synthetic.main.fragment_main.*


class DetailFragment : Fragment(R.layout.fragment_detail) {

    private val viewModel by viewModels<DetailViewModel> {
        AndroidViewModelFactory(requireActivity().application)
    }
    private val args: DetailFragmentArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val navController = findNavController()
        val appBarConfiguration = AppBarConfiguration(navController.graph)
        toolbar.setupWithNavController(navController, appBarConfiguration)

        //
        val binding = FragmentDetailBinding.bind(view)
        viewModel.getUser(args.id).observe(this.viewLifecycleOwner, Observer {
            binding.user = it
        })
    }
}