; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+m,+experimental-v < %s | FileCheck %s --check-prefix=RV32
; RUN: llc -mtriple=riscv64 -mattr=+m,+experimental-v < %s | FileCheck %s --check-prefix=RV64

; Check that we correctly scale the split part indirect offsets by VSCALE.
define <vscale x 32 x i32> @callee_scalable_vector_split_indirect(<vscale x 32 x i32> %x, <vscale x 32 x i32> %y) {
; RV32-LABEL: callee_scalable_vector_split_indirect:
; RV32:       # %bb.0:
; RV32-NEXT:    csrr a1, vlenb
; RV32-NEXT:    slli a1, a1, 3
; RV32-NEXT:    add a1, a0, a1
; RV32-NEXT:    vl8re32.v v24, (a0)
; RV32-NEXT:    vl8re32.v v0, (a1)
; RV32-NEXT:    vsetvli a0, zero, e32,m8,ta,mu
; RV32-NEXT:    vadd.vv v8, v8, v24
; RV32-NEXT:    vadd.vv v16, v16, v0
; RV32-NEXT:    ret
;
; RV64-LABEL: callee_scalable_vector_split_indirect:
; RV64:       # %bb.0:
; RV64-NEXT:    csrr a1, vlenb
; RV64-NEXT:    slli a1, a1, 3
; RV64-NEXT:    add a1, a0, a1
; RV64-NEXT:    vl8re32.v v24, (a0)
; RV64-NEXT:    vl8re32.v v0, (a1)
; RV64-NEXT:    vsetvli a0, zero, e32,m8,ta,mu
; RV64-NEXT:    vadd.vv v8, v8, v24
; RV64-NEXT:    vadd.vv v16, v16, v0
; RV64-NEXT:    ret
  %a = add <vscale x 32 x i32> %x, %y
  ret <vscale x 32 x i32> %a
}

; Call the function above. Check that we set the arguments correctly.
define <vscale x 32 x i32> @caller_scalable_vector_split_indirect(<vscale x 32 x i32> %x) {
; RV32-LABEL: caller_scalable_vector_split_indirect:
; RV32:       # %bb.0:
; RV32-NEXT:    addi sp, sp, -48
; RV32-NEXT:    .cfi_def_cfa_offset 48
; RV32-NEXT:    sw ra, 44(sp) # 4-byte Folded Spill
; RV32-NEXT:    .cfi_offset ra, -4
; RV32-NEXT:    csrr a0, vlenb
; RV32-NEXT:    slli a0, a0, 4
; RV32-NEXT:    sub sp, sp, a0
; RV32-NEXT:    csrr a0, vlenb
; RV32-NEXT:    slli a0, a0, 3
; RV32-NEXT:    addi a1, sp, 32
; RV32-NEXT:    add a0, a1, a0
; RV32-NEXT:    vs8r.v v16, (a0)
; RV32-NEXT:    addi a0, sp, 32
; RV32-NEXT:    vs8r.v v8, (a0)
; RV32-NEXT:    vsetvli a0, zero, e32,m8,ta,mu
; RV32-NEXT:    vmv.v.i v8, 0
; RV32-NEXT:    addi a0, sp, 32
; RV32-NEXT:    vmv8r.v v16, v8
; RV32-NEXT:    call callee_scalable_vector_split_indirect@plt
; RV32-NEXT:    csrr a0, vlenb
; RV32-NEXT:    slli a0, a0, 4
; RV32-NEXT:    add sp, sp, a0
; RV32-NEXT:    lw ra, 44(sp) # 4-byte Folded Reload
; RV32-NEXT:    addi sp, sp, 48
; RV32-NEXT:    ret
;
; RV64-LABEL: caller_scalable_vector_split_indirect:
; RV64:       # %bb.0:
; RV64-NEXT:    addi sp, sp, -32
; RV64-NEXT:    .cfi_def_cfa_offset 32
; RV64-NEXT:    sd ra, 24(sp) # 8-byte Folded Spill
; RV64-NEXT:    .cfi_offset ra, -8
; RV64-NEXT:    csrr a0, vlenb
; RV64-NEXT:    slli a0, a0, 4
; RV64-NEXT:    sub sp, sp, a0
; RV64-NEXT:    csrr a0, vlenb
; RV64-NEXT:    slli a0, a0, 3
; RV64-NEXT:    addi a1, sp, 24
; RV64-NEXT:    add a0, a1, a0
; RV64-NEXT:    vs8r.v v16, (a0)
; RV64-NEXT:    addi a0, sp, 24
; RV64-NEXT:    vs8r.v v8, (a0)
; RV64-NEXT:    vsetvli a0, zero, e32,m8,ta,mu
; RV64-NEXT:    vmv.v.i v8, 0
; RV64-NEXT:    addi a0, sp, 24
; RV64-NEXT:    vmv8r.v v16, v8
; RV64-NEXT:    call callee_scalable_vector_split_indirect@plt
; RV64-NEXT:    csrr a0, vlenb
; RV64-NEXT:    slli a0, a0, 4
; RV64-NEXT:    add sp, sp, a0
; RV64-NEXT:    ld ra, 24(sp) # 8-byte Folded Reload
; RV64-NEXT:    addi sp, sp, 32
; RV64-NEXT:    ret
  %c = alloca i64
  %a = call <vscale x 32 x i32> @callee_scalable_vector_split_indirect(<vscale x 32 x i32> zeroinitializer, <vscale x 32 x i32> %x)
  ret <vscale x 32 x i32> %a
}
