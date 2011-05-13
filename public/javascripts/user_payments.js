jQuery('document').ready(function(){

  if (jQuery('a[id^="previous-earnings-link-"]')){
    jQuery('a[id^="pending-earnings-link-"]').bind('click', function() {
      jQuery(jQuery(this).attr('href')).show();
    });
  }


  if (jQuery('a[id^="pending-hide-earnings-"]')){
    jQuery('a[id^="pending-hide-earnings-"]').bind('click', function() {
      jQuery(jQuery(this).attr('href')).hide();
    });
  }


  jQuery('#pending-earnings-link').click(function() {
    jQuery.ajax({
      url: "/users/monthly_pending_earnings",
      data: "user_id=" + getParameterByName("user_id"),
      success: function(data){
        jQuery("#pending-earnings").show();
        jQuery("#pending-earnings").html(data);


 
        jQuery('a[id^="pending-earnings-link-"]').bind('click', function() {
          jQuery(jQuery(this).attr('href')).show();
        });

        jQuery('a[id^="pending-hide-earnings-"]').bind('click', function() {
          jQuery(jQuery(this).attr('href')).hide();
        });

        jQuery('a[id^="pending-pay-button-"]').bind('click', function() {
          jQuery.ajax({
            url: "/admin/pay_pending_payments",
            data: "user_id=" + getParameterByName("user_id") + "&date=" + jQuery(this).attr('value'),
            success: function(data){
              $('#paid-earnings-link').trigger('click');
            }
          });
        });

      }
    })
  });

  jQuery('#paid-earnings-link').click(function() {
    jQuery.ajax({
      url: "/users/monthly_paid_earnings",
      data: "user_id=" + getParameterByName("user_id"),
      success: function(data){
        jQuery("#paid-earnings").show();
        jQuery("#paid-earnings").html(data);

        jQuery('a[id^="paid-earnings-link-"]').bind('click', function() {
          jQuery(jQuery(this).attr('value')).show();
        });

        jQuery('a[id^="paid-hide-earnings-"]').bind('click', function() {

          jQuery(jQuery(this).attr('value')).hide();
          jQuery('div[id*="-earnings-container"]').show();
        });

      }
    });
  });


  jQuery('a[id^="pending-pay-button-"]').click(function() {
    jQuery.ajax({
      url: "/admin/pay_pending_payments",
      data: "user_id=" + getParameterByName("user_id") + "&date=" + jQuery(this).attr('value'),
      success: function(data){
        $('#paid-earnings-link').trigger('click');
      }
    });
  })

});

function getParameterByName( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}
