<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script lang="ts">
  import { sayHello } from "./lib/nomuna";

  interface Props {
    label: string;
  }

  let { label }: Props = $props();

  let input: string = $state("");
  let output: string = $state("");

  function onNameInput() {
    output = sayHello(input);
  }
</script>

<p class="flex items-baseline gap-2">
  <span>{label}:</span>
  <input
    type="text"
    placeholder="Name"
    class="input input-bordered w-full max-w-xs"
    bind:value={input}
    oninput={(e) => onNameInput()}
  />
  <span>:</span>
  <span class="min-w-24">{output}</span>
</p>
