const multiply = function(x) {
  return x * 2;
}

const helper = function() {
  let val = multiply(10);
  if (val === 20) {
    console.log(val);
  }
}

module.exports = { multiply, helper };
