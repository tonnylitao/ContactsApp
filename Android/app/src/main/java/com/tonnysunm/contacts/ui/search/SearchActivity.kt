package com.tonnysunm.contacts.ui.search

import android.content.Context
import android.os.Bundle
import android.view.inputmethod.InputMethodManager
import android.widget.ImageView
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SearchView
import androidx.core.view.isVisible
import com.tonnysunm.contacts.R
import kotlinx.android.synthetic.main.activity_search.*


class SearchActivity : AppCompatActivity(R.layout.activity_search) {

    private val sharedViewModel by viewModels<SearchSharedViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val imm =
            searchView.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(searchView, 0)
        searchView.requestFocus()

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

        //not recommend using search_close_btn id
        val closeButton = searchView.findViewById<ImageView>(R.id.search_close_btn)
        closeButton.setOnClickListener {
            searchView.clearFocus()
            imm.hideSoftInputFromWindow(searchView.windowToken, 0)

            finish()
            overridePendingTransition(0, 0)
        }
        closeButton.isVisible = true
    }
}