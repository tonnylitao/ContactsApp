package com.tonnysunm.contacts.ui.search

import android.content.Context
import android.os.Bundle
import android.view.inputmethod.InputMethodManager
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SearchView
import com.tonnysunm.contacts.R
import kotlinx.android.synthetic.main.activity_search.*
import timber.log.Timber


class SearchActivity : AppCompatActivity(R.layout.activity_search) {

    private val sharedViewModel by viewModels<SearchSharedViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val imm =
            searchView.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
        searchView.requestFocus()

        searchView.setOnCloseListener {
            Timber.d("setOnCloseListener")

            return@setOnCloseListener false
        }

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

        view_pager.adapter = SectionsPagerAdapter(this, supportFragmentManager)

        tabs.setupWithViewPager(view_pager)
    }
}