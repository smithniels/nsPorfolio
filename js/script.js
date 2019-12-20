$(document).ready(function() {
  $("#header").headroom();
});

// Siema means 'hello' in Polish
var slideIndex = 0;
var numSlides = 4;

const slideshow = new Siema({
  selector: ".slider",
  loop: true,
  threshold: 200,
  easing: "cubic-bezier(.17,.67,.32,1.34)"
});

$(".prev").on("click", function() {
  slideshow.prev();
});

$(".next").on("click", function() {
  slideshow.next();
});
