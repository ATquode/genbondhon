<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script>
  import AddStringRow from "./AddStringRow.svelte";
  import SelectDirectionRow from "./SelectDirectionRow.svelte";
</script>

<div class="card w-[48%] bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">Input</h2>
    <AddStringRow label="String" />
    <SelectDirectionRow />
  </div>
</div>
