const colors = ["#69dfd2", "red", "green"];
const btn = document.getElementByID("btn");
const color = document.querySelector(".color");

btn.addEventListener("click", function () {
  const randomNumber = 2;
  document.body.style.backgroundColor = colors[randomNumber];
  color.textContent = colors[randomNumber]
});
