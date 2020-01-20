
$(document).ready(function() {

// What's wide???
$.each( $('*'), function() { 
  // console.log("is something too wide?")
  if( $(this).width() > $('body').width()) {
      console.log("Wide Element: ", $(this), "Width: ", $(this).width()); 
  } 
  else{console.log("no extra widths!")}
});

//OWL
$(".owl-carousel").owlCarousel({
  loop: true,
  margin: 10,
  nav: false,
  navText: [
    '<svg width="50" height="50" viewBox="0 0 24 24"><path d="M16.67 0l2.83 2.829-9.339 9.175 9.339 9.167-2.83 2.829-12.17-11.996z"/></svg>',
    '<svg width="50" height="50" viewBox="0 0 24 24"><path d="M5 3l3.057-3 11.943 12-11.943 12-3.057-3 9-9z"/></svg>'
    // VIEWBOX^ IS POSITION WITHIN THE BOX
  ],
  pagination: false, 
  dots: true,
  lazyLoad: true,
  autoplay: true,
  autoplayHoverPause: true,
  autoplaySpeed: 2000,
  slideSpeed: 3000,
  paginationSpeed: 9000,
  stagePadding: 70,
  responsiveClass:true,
  responsive: {
    0: {
      // stagePadding: 0,
      items: 1,
      dots: false,
    },
    600: {
      stagePadding: 0,
      items: 1
    },
    1000: {
      items: 1
    }
  }
});
$('.owl-carousel').owlCarousel({
  items:1,
  margin:10,
  // autoHeight:true
});

// BROKEN SCROLL THING
// scrolly header bits
// Credit to Marius Craciunoiu
// Hide Header on on scroll down
// Hide Header on on scroll down
var didScroll;
var lastScrollTop = 0;
var delta = 5;
var navbarHeight = $('header').outerHeight();

$(window).scroll(function(event){
    didScroll = true;
});

setInterval(function() {
    if (didScroll) {
        hasScrolled();
        didScroll = false;
    }
}, 250);

function hasScrolled() {
    var st = $(this).scrollTop();
    
    // Make sure they scroll more than delta
    if(Math.abs(lastScrollTop - st) <= delta)
        return;
    
    // If they scrolled down and are past the navbar, add class .nav-up.
    // This is necessary so you never see what is "behind" the navbar.
    if (st > lastScrollTop && st > navbarHeight){
        // Scroll Down
        $('header').removeClass('nav-down').addClass('nav-up');
    } else {
        // Scroll Up
        console.log("just wondering if this activates...")
        if(st + $(window).height() < $(document).height()) {
            $('header').removeClass('nav-up').addClass('nav-down');
        }
    }
    
    lastScrollTop = st;
}

// scrolly bits => bottom to top
$(window).scroll(function(){
  console.log('is this thing on?')
  if ($(this).scrollTop() > 100) {
    // Is the window more than 100px (maybe pixels...) away?
      $('#scroll').fadeIn();
      // if yes, turn on the scroll button
  } else {
      $('#scroll').fadeOut();
  }
});
$('#scroll').click(function(){
  $("html, body").animate({ scrollTop: 0 }, 800);
  console.log('To The Top!')
  return false;
});


});