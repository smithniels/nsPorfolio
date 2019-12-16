// 4 part slidey bits
$(document).ready(function() {
  // $('.slider').bxSlider();
  $(".slider").bxSlider({
    // https://bxslider.com/options/
    mode: "vertical",
    keyboardEnabled: true,
    minSlides: 3,
    maxSlides: 1,
    pager: false,
    control: true,
    repeat: true,
    // ticker: false,
    control: true
  });

  //

  //
});

// import "./styles.css";
//
// // first import.
// import Headroom from "headroom.js";
//
// // grab the header element.
// const Header = document.querySelector("nav");
//
// // construct an instance of Headroom, passing the header elemen.
// const headroom = new Headroom(Header, {
//   offset: 0,
//   tolerance: {
//     up: 0,
//     down: 0
//   },
//   classes: {
//     initial: "header--fixed",
//     pinned: "slideDown",
//     unpinned: "slideUp",
//     top: "top",
//     notTop: "not-top"
//   }
// });
//
// // initialise
// headroom.init();
//
// // When the page is at the top, remove the slideDown class.
// window.addEventListener("scroll", () => {
//   if (window.pageYOffset === 0) {
//     Header.classList.remove("slideDown");
//   }
// });
// //
