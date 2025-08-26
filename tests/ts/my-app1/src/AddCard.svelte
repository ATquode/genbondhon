<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

<script lang="ts">
  import AddRow from "./AddRow.svelte";
  import { isInt, isDecimal } from "validator";
  import { addDouble, addFloat, addIntNum } from "./lib/nomuna";

  function intValidator(value: string): boolean {
    return isInt(value);
  }

  function doubleValidator(value: string): boolean {
    return isDecimal(value, { decimal_digits: "1,4" });
  }

  function floatValidator(value: string): boolean {
    return isDecimal(value, { decimal_digits: "1,2" });
  }
</script>

<div class="card w-[48%] bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">Add</h2>
    <AddRow label="Int" validationFunc={intValidator} addFunc={addIntNum} />
    <AddRow
      label="Double"
      validationFunc={doubleValidator}
      addFunc={addDouble}
    />
    <AddRow label="Float" validationFunc={floatValidator} addFunc={addFloat} />
  </div>
</div>
