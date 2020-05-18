// Fade Into/Out of page
// Fade Into/Out of page
// Fade Into/Out of page
// Thanks  Christopher Vue https://christopheraue.net/design/fading-pages-on-load-and-unload

function fadeInPage() {
    if (!window.AnimationEvent) {
        return;
    }
    var fader = document.getElementById('fader');
    fader.classList.add('fade-out');
}

document.addEventListener('DOMContentLoaded', function() {
    if (!window.AnimationEvent) {
        return;
    }

    var anchors = document.getElementsByTagName('a');

    for (var idx = 0; idx < anchors.length; idx += 1) {
        if (anchors[idx].hostname !== window.location.hostname ||
            anchors[idx].pathname === window.location.pathname) {
            continue;
        }

        anchors[idx].addEventListener('click', function(event) {
            var fader = document.getElementById('fader'),
                anchor = event.currentTarget;

            var listener = function() {
                window.location = anchor.href;
                fader.removeEventListener('animationend', listener);
            };
            fader.addEventListener('animationend', listener);

            event.preventDefault();

            fader.classList.add('fade-in');
        });
    }
});



// Mostly annoying  title effect that should probably contained   to just one one page, but who knows
// Mostly annoying  title effect that should probably contained   to just one one page, but who knows
// Mostly annoying  title effect that should probably contained   to just one one page, but who knows

const hero = document.querySelector('.hero');
const text = hero.querySelector('h1');

function shadow(e) {
    let walk = 10; // Niels Note <-- this changes the range of the annoying effect. If I ever decide to have a click event to turn that off this would be the var to target. Just set it to zero :D 
    const {
        offsetWidth: width,
        offsetHeight: height
    } = hero;
    let {
        offsetX: x,
        offsetY: y
    } = e;

    if (this !== e.target) {
        x = x + e.target.offsetLeft;
        y = y + e.target.offsetTop;
    }

    const xWalk = Math.round((x / width * walk) - (walk / 20));
    const yWalk = Math.round((y / height * walk) - (walk / 20));

    // ${xWalk * -1}px ${yWalk}px      0 #f0cd13,
    text.style.textShadow = `
          ${xWalk}px      ${yWalk}px      0 #000000, // JUST changing to all white to see what that looks like
          ${xWalk}px      ${yWalk}px      0 pink,
          ${xWalk}px      ${yWalk}px      0 pink;

//           ${xWalk}px      ${yWalk}px      0 #000000, // Pop Art COLORS (3)
//           ${yWalk}px      ${xWalk * -1}px 0 #f8ded7,
//           ${yWalk * -1}px ${xWalk}px      0 #ec3c37
      `

}


hero.addEventListener('mousemove', shadow);
hero.addEventListener('mousein', shadow);


//OWL
//OWL
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
    responsiveClass: true,
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
    items: 1,
    margin: 10,
    autoHeight: true
});


// scrolly header bits
// scrolly header bits
// scrolly header bits
// Credit to Marius Craciunoiu

// Hide Header on on scroll down
var didScroll;
var lastScrollTop = 0;
var delta = 5;
var navbarHeight = $('header').outerHeight();

$(window).scroll(function(event) {
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
    if (Math.abs(lastScrollTop - st) <= delta)

        return;

    // If they scrolled down and are past the navbar, add class .nav-up.
    // This is necessary so you never see what is "behind" the navbar.
    if (st > lastScrollTop && st > navbarHeight) {
        // Scroll Down
        $('header').removeClass('nav-down').addClass('nav-up');

    } else {
        // Scroll Up
        if (st + $(window).height() < $(document).height()) {
            $('header').removeClass('nav-up').addClass('nav-down');
        }
    }

    lastScrollTop = st;
}

// scroll-ee bits => bottom to top
// scroll-ee bits => bottom to top
// scroll-ee bits => bottom to top
$(window).scroll(function() {
    if ($(this).scrollTop() > 100) {
        // Is the window more than 100px away?
        $('#scroll').fadeIn();
        // if yes, turn on the scroll button
    } else {
        $('#scroll').fadeOut();
    }
});
$('#scroll').click(function() {
    $("html, body").animate({
        scrollTop: 0
    }, 800);
    console.log('To The Top!')
    return false;
});
