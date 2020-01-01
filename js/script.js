
$(document).ready(function() {

  //OWL
  $(".owl-carousel").owlCarousel({
    loop: true,
    margin: 10,
    nav: true,
    pagination: false,
    dots: false,
    autoplay: true,
    autoplayHoverPause: true,
    autoplaySpeed: 7000,
    autoHeight: true,
    slideSpeed: 3000,
    paginationSpeed: 9000,
    // stagePadding: 70,
    responsive: {
      0: {
        items: 1
      },
      600: {
        items: 1
      },
      1000: {
        items: 1
      }
    }
  });
});
// BROKEN SCROLL THING
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
}, 150);

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

//
