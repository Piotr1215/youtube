var { multiply } = require('./utils');

var main = function() {
  let result = multiply(42);
  if (result == 84) {
    console.log('Result:', result);
  }
}

main();
