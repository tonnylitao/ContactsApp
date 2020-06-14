package com.tonnysunm.contacts.ui.search

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.widget.SearchView
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.setupWithNavController
import com.tonnysunm.contacts.R
import kotlinx.android.synthetic.main.fragment_search_pager.*

class SearchPagerFragment : Fragment(R.layout.fragment_search_pager) {

    private val sharedViewModel by viewModels<SearchSharedViewModel>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean {
                sharedViewModel.setTarget(query)
                return true
            }

            override fun onQueryTextChange(newText: String?): Boolean {
                sharedViewModel.setTarget(newText)
                return true
            }
        })

        view_pager.adapter = SectionsPagerAdapter(requireContext(), childFragmentManager)
        tabs.setupWithViewPager(view_pager)

        /**
         * Support app bar variations
         * https://developer.android.com/guide/navigation/navigation-ui#support_app_bar_variations
         */
        val navController = findNavController()
        val appBarConfiguration = AppBarConfiguration(navController.graph)
        toolbar.setupWithNavController(navController, appBarConfiguration)
    }

    override fun onResume() {
        super.onResume()

        searchView.requestFocus()
        val imm =
            searchView.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY)
    }

    override fun onPause() {
        val imm =
            searchView.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(searchView.windowToken, 0)

        searchView.clearFocus()

        super.onPause()
    }
}