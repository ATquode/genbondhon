# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import compiler/ast

func procName*(node: PNode): string =
  ## get proc/func/method name from node
  ## Note: node needs to be proc/func/method type node,
  ## proc needs to be **public**
  node[0][1].ident.s
