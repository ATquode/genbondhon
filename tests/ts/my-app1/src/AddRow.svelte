<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script lang="ts">
  interface Props {
    label: string;
    validationFunc: (value: string) => boolean;
    addFunc: (a: number, b: number) => number;
  }

  let { label, validationFunc, addFunc }: Props = $props();

  let input1: string = $state("");
  let number1: number = $state(0);
  let input2: string = $state("");
  let number2: number = $state(0);
  let output: number = $state(0);

  function validateInput1(value: string) {
    validateInput(
      value,
      (num) => (number1 = num),
      (input) => (input1 = input),
      () => number1,
    );
  }

  function validateInput2(value: string) {
    validateInput(
      value,
      (num) => (number2 = num),
      (input) => (input2 = input),
      () => number2,
    );
  }

  function validateInput(
    value: string,
    setNumber: (num: number) => void,
    setInput: (input: string) => void,
    getNumber: () => number,
  ) {
    if (value === "") {
      setNumber(0);
      setInput("");
      output = addFunc(number1, number2);
      return;
    } else if (validationFunc(value)) {
      let num = +value;
      setNumber(num);
      output = addFunc(number1, number2);
      if (value.length > 0 && value.slice(-1) === "0") {
        return;
      }
    }
    setInput(getNumber().toString());
  }
</script>

<p class="flex items-baseline gap-2">
  <span>{label}:</span>
  <input
    type="number"
    placeholder="Number 1"
    class="input input-bordered w-full max-w-xs"
    bind:value={input1}
    oninput={(e) => validateInput1(e.currentTarget.value)}
  />
  <span>+</span>
  <input
    type="number"
    placeholder="Number 2"
    class="input input-bordered w-full max-w-xs"
    bind:value={input2}
    oninput={(e) => validateInput2(e.currentTarget.value)}
  />
  <span>=</span>
  <span>{output}</span>
</p>
