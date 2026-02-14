export default [
  {
    languageOptions: {
      globals: {
        require: "readonly",
        module: "readonly",
        console: "readonly"
      }
    },
    rules: {
      "no-var": "error",
      "prefer-const": "error",
      "eqeqeq": "error"
    }
  }
];
