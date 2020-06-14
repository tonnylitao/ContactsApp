package com.tonnysunm.contacts.ui.search

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter

class SectionsPagerAdapter(private val context: Context, fm: FragmentManager) :
    FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    override fun getItem(position: Int): Fragment {
        return SearchFragment.newInstance(position)
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return Filter.valueBy(position).title(context)
    }

    override fun getCount(): Int {
        return Filter.values().size
    }
}