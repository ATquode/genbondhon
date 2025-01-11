<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script lang="ts">
  import ConstRetRow from "./ConstRetRow.svelte";
  import {
    constRet,
    constRetBool,
    constRetChar,
    constRetFloat,
    constRetStr,
    constRetUnicodeStr,
  } from "./lib/nomuna";
</script>

<div class="card w-[48%] bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">Constant Returns</h2>
    <ConstRetRow label="Int" retValue={constRet().toString()} />
    <ConstRetRow label="Bool" retValue={constRetBool().toString()} />
    <ConstRetRow label="Double" retValue={constRetFloat().toString()} />
    <ConstRetRow
      label="Char"
      retValue={String.fromCharCode(parseInt(constRetChar()))}
    />
    <ConstRetRow label="String" retValue={constRetStr()} />
    <ConstRetRow label="Unicode String" retValue={constRetUnicodeStr()} />
  </div>
</div>
