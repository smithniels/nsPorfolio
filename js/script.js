// 4 part slidey bits
$(document).ready(function() {
  // $('.slider').bxSlider();
  $(".slider").bxSlider({
    // https://bxslider.com/options/
    mode: "vertical",
    keyboardEnabled: true,
    minSlides: 1,
    maxSlides: 1,
    pager: false,
    control: true,
    // ticker: false,
    control: true
  });
});

// scrolly header bits
// Credit to Marius Craciunoiu
// Hide Header on on scroll down
var didScroll;
var lastScrollTop = 0;
var delta = 5;
var navbarHeight = $("header").outerHeight();

$(window).scroll(function(event) {
  didScroll = true;
});

setInterval(function() {
  if (didScroll) {
    hasScrolled();
    didScroll = false;
  }
}, 350);

function hasScrolled() {
  var st = $(this).scrollTop();

  // Make sure they scroll more than delta
  if (Math.abs(lastScrollTop - st) <= delta) return;

  // If they scrolled down and are past the navbar, add class .nav-up.
  // This is necessary so you never see what is "behind" the navbar.
  if (st > lastScrollTop && st > navbarHeight) {
    // Scroll Down
    $("header")
      .removeClass("nav-down")
      .addClass("nav-up");
  } else {
    // Scroll Up
    if (st + $(window).height() < $(document).height()) {
      $("header")
        .removeClass("nav-up")
        .addClass("nav-down");
    }
  }

  lastScrollTop = st;
}

// $(".slider").slick({
//   slidesToShow: 1,
//   // slidesToScroll: 3,
//   dots: true,
//   infinite: true,
//   cssEase: "linear"
// });

// $(function() {
//   /* SET PARAMETERS */
//   var change_img_time = 5000;
//   var transition_speed = 100;
//
//   var simple_slideshow = $("#exampleSlider"),
//     listItems = simple_slideshow.children("li"),
//     listLen = listItems.length,
//     i = 0,
//     changeList = function() {
//       listItems.eq(i).fadeOut(transition_speed, function() {
//         i += 1;
//         if (i === listLen) {
//           i = 0;
//         }
//         listItems.eq(i).fadeIn(transition_speed);
//       });
//     };
//
//   listItems.not(":first").hide();
//   setInterval(changeList, change_img_time);
// });
