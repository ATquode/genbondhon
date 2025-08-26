<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script lang="ts">
  import { Direction, getOpposite } from "./lib/nomuna";

  let selectedDir: Direction = $state(Direction.North);
  let oppositeDir: Direction = $derived(getOpposite(selectedDir));

  function onSelectedDirection() {}
</script>

<p class="flex">
  <label class="label w-fit">
    <span class="label pr-4">Direction:</span>
    <select
      class="select"
      bind:value={selectedDir}
      oninput={() => onSelectedDirection()}
    >
      {#each Object.keys(Direction) as direction}
        <option value={Direction[direction as keyof typeof Direction]}
          >{direction}</option
        >
      {/each}
    </select>
  </label>
  <span class="content-center pl-4"
    >Opposite: {Object.keys(Direction)[
      Object.values(Direction).indexOf(oppositeDir)
    ]}</span
  >
</p>
