package com.fillcolor.coloringbook.paint.colorart
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class NativeMediaSmallFactory(private val layoutInflater: LayoutInflater) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.layout_native_small_media, null) as NativeAdView

        // Set the media view.
        adView.mediaView = adView.findViewById(R.id.ad_media)

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.iconView = adView.findViewById(R.id.ad_app_icon)

        // The headline and mediaView are guaranteed to be in every NativeAd.
        (adView.headlineView as TextView).text = nativeAd.headline
        adView.mediaView?.setMediaContent(nativeAd.mediaContent!!)

        // These assets aren't guaranteed to be in every NativeAd, so it's important to check before trying to display them.
        if (nativeAd.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        val cardIcon: View? = adView.findViewById(R.id.card_icon)
        if (nativeAd.icon == null) {
            cardIcon?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
            cardIcon?.visibility = View.VISIBLE
        }


        // This method tells the Google Mobile Ads SDK that you have finished setting your ad assets, 
        // and that the ad is now ready to be displayed.
        adView.setNativeAd(nativeAd)

        return adView
    }
}
