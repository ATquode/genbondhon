<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script lang="ts">
  interface Props {
    label: string;
    retValue: string;
  }

  let { label, retValue }: Props = $props();
</script>

<p>{label}: {retValue}</p>
