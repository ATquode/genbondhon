<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script lang="ts">
  import AddCard from "./AddCard.svelte";
  import ConstRetCard from "./ConstRetCard.svelte";
  import DefaultView from "./DefaultView.svelte";
</script>

<main class="place-items-center p-4 mt-8">
  <div class="flex flex-wrap gap-4">
    <ConstRetCard />
    <AddCard />
  </div>
  <DefaultView />
</main>
