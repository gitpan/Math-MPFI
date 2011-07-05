#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#if defined USE_64_BIT_INT
#ifndef _MSC_VER
#include <inttypes.h>
#endif
#endif

#include <mpfi.h>
#include <mpfi_io.h>

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef __gmpfr_default_rounding_mode
#define __gmpfr_default_rounding_mode mpfr_get_default_rounding_mode()
#endif

/* Has inttypes.h been included ? */
int _has_inttypes() {
#ifdef _MSC_VER
return 0;
#else
#if defined USE_64_BIT_INT
return 1;
#else
return 0;
#endif
#endif
}

int _has_longlong() {
#ifdef USE_64_BIT_INT
    return 1;
#else
    return 0;
#endif
}

int _has_longdouble() {
#ifdef USE_LONG_DOUBLE
    return 1;
#else
    return 0;
#endif
}

/*******************************
Rounding Modes and Precision Handling
*******************************/

SV * RMPFI_BOTH_ARE_EXACT (int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_BOTH_ARE_EXACT");
     if(MPFI_BOTH_ARE_EXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

SV * RMPFI_LEFT_IS_INEXACT (int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_LEFT_IS_INEXACT");
     if(MPFI_LEFT_IS_INEXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

SV * RMPFI_RIGHT_IS_INEXACT (int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_RIGHT_IS_INEXACT");
     if(MPFI_RIGHT_IS_INEXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

SV * RMPFI_BOTH_ARE_INEXACT (int ret) {
     if(ret > 3 || ret < 0) croak("Unacceptable value passed to RMPFI_BOTH_ARE_INEXACT");
     if(MPFI_BOTH_ARE_INEXACT(ret)) return &PL_sv_yes;
     return &PL_sv_no;
}

void _Rmpfi_set_default_prec(SV * p) {
     mpfr_set_default_prec((mp_prec_t)SvUV(p));
}

SV * Rmpfi_get_default_prec() {
     return newSVuv(mpfr_get_default_prec());
}  

void Rmpfi_set_prec(mpfi_t * op, SV * prec) {
     mpfi_set_prec(*op, (mp_prec_t)SvUV(prec));
}

SV * Rmpfi_get_prec(mpfi_t * op) {
     return newSVuv(mpfi_get_prec(*op));
}

SV * Rmpfi_round_prec(mpfi_t * op, SV * prec) {
     return newSViv(mpfi_round_prec(*op, (mp_prec_t)SvUV(prec)));
}

/*******************************
Initialization Functions
*******************************/

SV * Rmpfi_init() {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_init_nobless() {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     mpfi_init(*mpfi_t_obj);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_init2(SV * prec) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init2 function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init2 (*mpfi_t_obj, (mp_prec_t)SvUV(prec));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_init2_nobless(SV * prec) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init2_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     mpfi_init2 (*mpfi_t_obj, (mp_prec_t)SvUV(prec));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

void DESTROY(mpfi_t * p) {
     mpfi_clear(*p);
     Safefree(p);
}

void Rmpfi_clear(mpfi_t * p) {
     mpfi_clear(*p);
     Safefree(p);
}

/*******************************
Assignment Functions
*******************************/

SV * Rmpfi_set (mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_set(*rop, *op));
}

SV * Rmpfi_set_ui (mpfi_t * rop, SV * op) {
     return newSViv(mpfi_set_ui(*rop, SvUV(op)));
}

SV * Rmpfi_set_si (mpfi_t * rop, SV * op) {
     return newSViv(mpfi_set_si(*rop, SvIV(op)));
}

SV * Rmpfi_set_d (mpfi_t * rop, SV * op) {
     return newSViv(mpfi_set_d(*rop, SvNV(op)));
}

SV * Rmpfi_set_z (mpfi_t * rop, mpz_t * op) {
     return newSViv(mpfi_set_z(*rop, *op));
}

SV * Rmpfi_set_q (mpfi_t * rop, mpq_t * op) {
     return newSViv(mpfi_set_q(*rop, *op));
}

SV * Rmpfi_set_fr (mpfi_t * rop, mpfr_t * op) {
     return newSViv(mpfi_set_fr(*rop, *op));
}

SV * Rmpfi_set_str (mpfi_t * rop, SV * s, SV * base) {
     return newSViv(mpfi_set_str(*rop, SvPV_nolen(s), SvIV(base)));
}

void Rmpfi_swap (mpfi_t * x, mpfi_t * y) {
     mpfi_swap(*x, *y);
}

/*******************************
Combined Initialization and Assignment Functions
*******************************/

void Rmpfi_init_set(mpfi_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_ui(SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_ui function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_ui(*mpfi_t_obj, (unsigned long)SvUV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_si(SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_si function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_si(*mpfi_t_obj, (long)SvIV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_d(SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_d function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_d(*mpfi_t_obj, (double)SvNV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_z(mpz_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_z function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_z(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_q(mpq_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_q function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_q(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_fr(mpfr_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_fr function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     ret = mpfi_init_set_fr(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_str(SV * q, SV * base) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret = (int)SvIV(base);

     if(ret < 0 || ret > 36 || ret == 1) croak("2nd argument supplied to Rmpfi_init_set str is out of allowable range");

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_str function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ret = mpfi_init_set_str(*mpfi_t_obj, SvPV_nolen(q), ret);

     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

/**********************************
 The nobless variants
***********************************/

void Rmpfi_init_set_nobless(mpfi_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_ui_nobless(SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_ui_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_ui(*mpfi_t_obj, (unsigned long)SvUV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_si_nobless(SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_si_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_si(*mpfi_t_obj, (long)SvIV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_d_nobless(SV * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_d_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_d(*mpfi_t_obj, (double)SvNV(q));

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_z_nobless(mpz_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_z_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_z(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_q_nobless(mpq_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_q_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_q(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_fr_nobless(mpfr_t * q) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_fr_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfi_init_set_fr(*mpfi_t_obj, *q);

     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

void Rmpfi_init_set_str_nobless(SV * q, SV * base) {
     dXSARGS;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;
     int ret = (int)SvIV(base);

     if(ret < 0 || ret > 36 || ret == 1) croak("2nd argument supplied to Rmpfi_init_set str is out of allowable range");

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_init_set_str_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     ret = mpfi_init_set_str(*mpfi_t_obj, SvPV_nolen(q), ret);

     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}


/*******************************
Interval Functions with Floating-point Results
*******************************/

SV * Rmpfi_diam_abs(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_diam_abs(*rop, *op));
}

SV * Rmpfi_diam_rel(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_diam_rel(*rop, *op));
}

SV * Rmpfi_diam(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_diam(*rop, *op));
}

SV * Rmpfi_mag(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_mag(*rop, *op));
}

SV * Rmpfi_mig(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_mig(*rop, *op));
}

SV * Rmpfi_mid(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_mid(*rop, *op));
}

void Rmpfi_alea(mpfr_t * rop, mpfi_t * op) {
     mpfi_alea(*rop, *op);
}

/*******************************
Conversion Functions
*******************************/

SV * Rmpfi_get_d (mpfi_t * op) {
     return newSVnv(mpfi_get_d(*op));
}

void Rmpfi_get_fr(mpfr_t * rop, mpfi_t * op) {
     mpfi_get_fr(*rop, *op);
}

/*******************************
Basic Arithmetic Functions
*******************************/

SV * Rmpfi_add (mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_add(*rop, *op1, *op2));
}

SV * Rmpfi_add_d (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_add_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_add_ui (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_add_ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_add_si (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_add_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_add_z (mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_add_z(*rop, *op1, *op2));
}

SV * Rmpfi_add_q (mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_add_q(*rop, *op1, *op2));
}

SV * Rmpfi_add_fr (mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_add_fr(*rop, *op1, *op2));
}

SV * Rmpfi_sub (mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_sub(*rop, *op1, *op2));
}

SV * Rmpfi_sub_d (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_sub_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_d_sub (mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_d_sub(*rop, SvNV(op1), *op2));
}

SV * Rmpfi_sub_ui (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_sub_ui(*rop, *op1, SvUV(op2)));
}
SV * Rmpfi_ui_sub (mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_ui_sub(*rop, SvUV(op1), *op2));
}

SV * Rmpfi_sub_si (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_sub_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_si_sub (mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_si_sub(*rop, SvIV(op1), *op2));
}

SV * Rmpfi_sub_z (mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_sub_z(*rop, *op1, *op2));
}

SV * Rmpfi_z_sub (mpfi_t * rop, mpz_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_z_sub(*rop, *op1, *op2));
}

SV * Rmpfi_sub_q (mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_sub_q(*rop, *op1, *op2));
}

SV * Rmpfi_q_sub (mpfi_t * rop, mpq_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_q_sub(*rop, *op1, *op2));
}

SV * Rmpfi_sub_fr (mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_sub_fr(*rop, *op1, *op2));
}

SV * Rmpfi_fr_sub (mpfi_t * rop, mpfr_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_fr_sub(*rop, *op1, *op2));
}

SV * Rmpfi_mul (mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_mul(*rop, *op1, *op2));
}

SV * Rmpfi_mul_d (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_mul_ui (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_mul_si (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_mul_z (mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_mul_z(*rop, *op1, *op2));
}

SV * Rmpfi_mul_q (mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_mul_q(*rop, *op1, *op2));
}

SV * Rmpfi_mul_fr (mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_mul_fr(*rop, *op1, *op2));
}

SV * Rmpfi_div (mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_div(*rop, *op1, *op2));
}

SV * Rmpfi_div_d (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_d(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_d_div (mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_d_div(*rop, SvNV(op1), *op2));
}

SV * Rmpfi_div_ui (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_ui_div (mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_ui_div(*rop, SvUV(op1), *op2));
}

SV * Rmpfi_div_si (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_si_div (mpfi_t * rop, SV * op1, mpfi_t * op2) {
     return newSViv(mpfi_si_div(*rop, SvIV(op1), *op2));
}

SV * Rmpfi_div_z (mpfi_t * rop, mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_div_z(*rop, *op1, *op2));
}

SV * Rmpfi_z_div (mpfi_t * rop, mpz_t * op1, mpfi_t *op2) {
     return newSViv(mpfi_z_div(*rop, *op1, *op2));
}

SV * Rmpfi_div_q (mpfi_t * rop, mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_div_q(*rop, *op1, *op2));
}

SV * Rmpfi_q_div (mpfi_t * rop, mpq_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_q_div(*rop, *op1, *op2));
}

SV * Rmpfi_div_fr (mpfi_t * rop, mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_div_fr(*rop, *op1, *op2));
}

SV * Rmpfi_fr_div (mpfi_t * rop, mpfr_t *op1, mpfi_t * op2) {
     return newSViv(mpfi_fr_div(*rop, *op1, *op2));
}

SV * Rmpfi_neg(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_neg(*rop, *op));
}

SV * Rmpfi_sqr(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sqr(*rop, *op));
}

SV * Rmpfi_inv(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_inv(*rop, *op));
}

SV * Rmpfi_sqrt(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sqrt(*rop, *op));
}

SV * Rmpfi_abs(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_abs(*rop, *op));
}

SV * Rmpfi_mul_2exp (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_2exp(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_mul_2ui (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_2ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_mul_2si (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_mul_2si(*rop, *op1, SvIV(op2)));
}

SV * Rmpfi_div_2exp (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_2exp(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_div_2ui (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_2ui(*rop, *op1, SvUV(op2)));
}

SV * Rmpfi_div_2si (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_div_2si(*rop, *op1, SvIV(op2)));
}

/*******************************
Special Functions
*******************************/

SV * Rmpfi_log(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log(*rop, *op));
}

SV * Rmpfi_exp(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_exp(*rop, *op));
}

SV * Rmpfi_exp2(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_exp2(*rop, *op));
}

SV * Rmpfi_cos(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cos(*rop, *op));
}

SV * Rmpfi_sin(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sin(*rop, *op));
}

SV * Rmpfi_tan(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_tan(*rop, *op));
}

SV * Rmpfi_acos(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_acos(*rop, *op));
}

SV * Rmpfi_asin(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_asin(*rop, *op));
}

SV * Rmpfi_atan(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_atan(*rop, *op));
}

SV * Rmpfi_cosh(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cosh(*rop, *op));
}

SV * Rmpfi_sinh(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sinh(*rop, *op));
}

SV * Rmpfi_tanh(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_tanh(*rop, *op));
}

SV * Rmpfi_acosh(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_acosh(*rop, *op));
}

SV * Rmpfi_asinh(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_asinh(*rop, *op));
}

SV * Rmpfi_atanh(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_atanh(*rop, *op));
}

SV * Rmpfi_log1p(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log1p(*rop, *op));
}

SV * Rmpfi_expm1(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_expm1(*rop, *op));
}

SV * Rmpfi_log2(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log2(*rop, *op));
}

SV * Rmpfi_log10(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_log10(*rop, *op));
}

SV * Rmpfi_const_log2(mpfi_t * op) {
     return newSViv(mpfi_const_log2(*op));
}

SV * Rmpfi_const_pi(mpfi_t * op) {
     return newSViv(mpfi_const_pi(*op));
}

SV * Rmpfi_const_euler(mpfi_t * op) {
     return newSViv(mpfi_const_euler(*op));
}

/*******************************
Comparison Functions
*******************************/

SV * Rmpfi_cmp (mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_cmp(*op1, *op2));
}

SV * Rmpfi_cmp_d (mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_cmp_d(*op1, SvNV(op2)));
}

SV * Rmpfi_cmp_ui (mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_cmp_ui(*op1, SvUV(op2)));
}

SV * Rmpfi_cmp_si (mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_cmp_si(*op1, SvIV(op2)));
}

SV * Rmpfi_cmp_z (mpfi_t * op1, mpz_t * op2) {
     return newSViv(mpfi_cmp_z(*op1, *op2));
}

SV * Rmpfi_cmp_q (mpfi_t * op1, mpq_t * op2) {
     return newSViv(mpfi_cmp_q(*op1, *op2));
}

SV * Rmpfi_cmp_fr (mpfi_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_cmp_fr(*op1, *op2));
}

SV * Rmpfi_is_pos(mpfi_t * op) {
     return newSViv(mpfi_is_pos(*op));
}

SV * Rmpfi_is_strictly_pos(mpfi_t * op) {
     return newSViv(mpfi_is_strictly_pos(*op));
}

SV * Rmpfi_is_nonneg(mpfi_t * op) {
     return newSViv(mpfi_is_nonneg(*op));
}

SV * Rmpfi_is_neg(mpfi_t * op) {
     return newSViv(mpfi_is_neg(*op));
}

SV * Rmpfi_is_strictly_neg(mpfi_t * op) {
     return newSViv(mpfi_is_strictly_neg(*op));
}

SV * Rmpfi_is_nonpos(mpfi_t * op) {
     return newSViv(mpfi_is_nonpos(*op));
}

SV * Rmpfi_is_zero(mpfi_t * op) {
     return newSViv(mpfi_is_zero(*op));
}

SV * Rmpfi_has_zero(mpfi_t * op) {
     return newSViv(mpfi_has_zero(*op));
}

SV * Rmpfi_nan_p(mpfi_t * op) {
     return newSViv(mpfi_nan_p(*op));
}

SV * Rmpfi_inf_p(mpfi_t * op) {
     return newSViv(mpfi_inf_p(*op));
}

SV * Rmpfi_bounded_p(mpfi_t * op) {
     return newSViv(mpfi_bounded_p(*op));
}

/*******************************
Input and Output Functions
*******************************/

SV * _Rmpfi_out_str(FILE * stream, SV * base, SV * dig, mpfi_t * p) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("2nd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfi_out_strS(FILE * stream, SV * base, SV * dig, mpfi_t * p, SV * suff) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("2nd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfi_out_strP(SV * pre, FILE * stream, SV * base, SV * dig, mpfi_t * p) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("3rd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfi_out_strPS(SV * pre, FILE * stream, SV * base, SV * dig, mpfi_t * p, SV * suff) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("3rd argument supplied to Rmpfi_out_str is out of allowable range (must be between 2 and 36 inclusive)");
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpfi_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p);
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * Rmpfi_inp_str(mpfi_t * p, FILE * stream, SV * base) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > 36) croak("3rd argument supplied to Rmpfi_inp_str is out of allowable range (must be between 2 and 36 inclusive)");
     ret = mpfi_inp_str(*p, stream, (int)SvIV(base));
     return newSVuv(ret);
}

void Rmpfi_print_binary(mpfi_t * op) {
     mpfi_print_binary(*op);
}

/*******************************
Functions Operating on Endpoints
*******************************/

SV * Rmpfi_get_left(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_get_left(*rop, *op));
}

SV * Rmpfi_get_right(mpfr_t * rop, mpfi_t * op) {
     return newSViv(mpfi_get_right(*rop, *op));
}

SV * Rmpfi_revert_if_needed(mpfi_t * op) {
     return newSViv(mpfi_revert_if_needed(*op));
}

SV * Rmpfi_put (mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_put(*rop, *op));
}

SV * Rmpfi_put_d (mpfi_t * rop, SV * op) {
     return newSViv(mpfi_put_d(*rop, SvNV(op)));
}

SV * Rmpfi_put_ui (mpfi_t * rop, SV * op) {
     return newSViv(mpfi_put_ui(*rop, SvUV(op)));
}

SV * Rmpfi_put_si (mpfi_t * rop, SV * op) {
     return newSViv(mpfi_put_si(*rop, SvIV(op)));
}

SV * Rmpfi_put_z (mpfi_t * rop, mpz_t * op) {
     return newSViv(mpfi_put_z(*rop, *op));
}

SV * Rmpfi_put_q (mpfi_t * rop, mpq_t * op) {
     return newSViv(mpfi_put_q(*rop, *op));
}

SV * Rmpfi_put_fr (mpfi_t * rop, mpfr_t * op) {
     return newSViv(mpfi_put_fr(*rop, *op));
}

SV * Rmpfi_interv_d (mpfi_t * rop, SV * op1, SV * op2) {
     return newSViv(mpfi_interv_d(*rop, SvNV(op1), SvNV(op2)));
}

SV * Rmpfi_interv_ui (mpfi_t * rop, SV * op1, SV * op2) {
     return newSViv(mpfi_interv_ui(*rop, SvUV(op1), SvUV(op2)));
}

SV * Rmpfi_interv_si (mpfi_t * rop, SV * op1, SV * op2) {
     return newSViv(mpfi_interv_si(*rop, SvIV(op1), SvIV(op2)));
}

SV * Rmpfi_interv_z (mpfi_t * rop, mpz_t * op1, mpz_t * op2) {
     return newSViv(mpfi_interv_z(*rop, *op1, *op2));
}

SV * Rmpfi_interv_q (mpfi_t * rop, mpq_t * op1, mpq_t * op2) {
     return newSViv(mpfi_interv_q(*rop, *op1, *op2));
}

SV * Rmpfi_interv_fr (mpfi_t * rop, mpfr_t * op1, mpfr_t * op2) {
     return newSViv(mpfi_interv_fr(*rop, *op1, *op2));
}

/*******************************
Set Functions on Intervals
*******************************/

SV * Rmpfi_is_strictly_inside (mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_is_strictly_inside(*op1, *op2));
}

SV * Rmpfi_is_inside (mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_is_inside(*op1, *op2));
}

SV * Rmpfi_is_inside_d (SV * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_d(SvNV(op2), *op1));
}

SV * Rmpfi_is_inside_ui (SV * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_ui(SvUV(op2), *op1));
}

SV * Rmpfi_is_inside_si (SV * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_si(SvIV(op2), *op1));
}

SV * Rmpfi_is_inside_z (mpz_t * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_z(*op2, *op1));
}

SV * Rmpfi_is_inside_q (mpq_t * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_q(*op2, *op1));
}

SV * Rmpfi_is_inside_fr (mpfr_t * op2, mpfi_t * op1) {
     return newSViv(mpfi_is_inside_fr(*op2, *op1));
}

SV * Rmpfi_is_empty (mpfi_t * op) {
     return newSViv(mpfi_is_empty(*op));
}

SV * Rmpfi_intersect (mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_intersect(*rop, *op1, *op2));
}

SV * Rmpfi_union (mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_union(*rop, *op1, *op2));
}

/*******************************
Miscellaneous Interval Functions
*******************************/

SV * Rmpfi_increase (mpfi_t * rop, mpfr_t * op) {
     return newSViv(mpfi_increase(*rop, *op));
}

SV * Rmpfi_blow (mpfi_t * rop, mpfi_t * op1, SV * op2) {
     return newSViv(mpfi_blow(*rop, *op1, SvNV(op2)));
}

SV * Rmpfi_bisect (mpfi_t * rop1, mpfi_t * rop2, mpfi_t * op) {
     return newSViv(mpfi_bisect(*rop1, *rop2, *op));
}

/*******************************
Error Handling
*******************************/

void RMPFI_ERROR (SV * msg) {
     MPFI_ERROR(SvPV_nolen(msg));
}

SV * Rmpfi_is_error() {
     return newSViv(mpfi_is_error());
}

void Rmpfi_set_error(SV * op) {
     mpfi_set_error(SvIV(op));
}

void Rmpfi_reset_error() {
     mpfi_reset_error();
}

SV * _itsa(SV * a) {
     if(SvUOK(a)) return newSVuv(1);
     if(SvIOK(a)) return newSVuv(2);
     if(SvNOK(a)) return newSVuv(3);
     if(SvPOK(a)) return newSVuv(4);
     if(sv_isobject(a)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::MPFR")) return newSVuv(5);
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::GMPf")) return newSVuv(6);
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::GMPq")) return newSVuv(7);
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::GMPz")) return newSVuv(8);
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::GMP")) return newSVuv(9);
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::MPC")) return newSVuv(10);
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::MPFI")) return newSVuv(11);
       }
     return newSVuv(0);
}

SV * gmp_v() {
     return newSVpv(gmp_version, 0);
}

SV * mpfr_v() {
     return newSVpv(mpfr_get_version(), 0);
}

/*******************************
Overloading
*******************************/

SV * overload_gte(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_gte");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret >= 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_gte");
}

SV * overload_lte(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_lte");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret <= 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_lte");
}

SV * overload_gt(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_gt");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret > 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_gt");
}

SV * overload_lt(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfi_nan_p(*a)) return newSViv(0);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       if(SvNV(b) != SvNV(b)) return 0;
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_lt");
       ret = mpfi_cmp_fr(*a, t);
       if(third == &PL_sv_yes) ret *= -1;
       mpfr_clear(t);
       if(ret < 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret < 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_lt");
}

SV * overload_equiv(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       ret = mpfi_cmp_ui(*a, SvUV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfi_cmp_si(*a, SvIV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       ret = mpfi_cmp_d(*a, SvNV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_equiv");
       ret = mpfi_cmp_fr(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         ret = mpfi_cmp(*a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         if(ret == 0) return newSViv(1);
         return newSViv(0);
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_equiv");
}

SV * overload_add(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_add function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_add_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfi_add_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_add_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_add");
       mpfi_add_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_add(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_add");
}

SV * overload_mul(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_mul function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_mul_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfi_mul_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_mul_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_mul");
       mpfi_mul_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_mul(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_mul");
}

SV * overload_sub(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_sub function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       if(third == &PL_sv_yes) mpfi_ui_sub(*mpfi_t_obj, SvUV(b), *a);
       else mpfi_sub_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       if(third == &PL_sv_yes) mpfi_si_sub(*mpfi_t_obj, SvIV(b), *a);
       else mpfi_sub_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(third == &PL_sv_yes) mpfi_d_sub(*mpfi_t_obj, SvNV(b), *a);
       else mpfi_sub_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_sub");
       if(third == &PL_sv_yes) mpfi_fr_sub(*mpfi_t_obj, t, *a);
       else mpfi_sub_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_sub(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_sub");
}

SV * overload_div(mpfi_t * a, SV * b, SV * third) {
     mpfr_t t;
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("%s", "Failed to allocate memory in overload_div function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       if(third == &PL_sv_yes) mpfi_ui_div(*mpfi_t_obj, SvUV(b), *a);
       else mpfi_div_ui(*mpfi_t_obj, *a, SvUV(b));
       return obj_ref;
       }

     if(SvIOK(b)) {
       if(third == &PL_sv_yes) mpfi_si_div(*mpfi_t_obj, SvIV(b), *a);
       else mpfi_div_si(*mpfi_t_obj, *a, SvIV(b));
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       if(third == &PL_sv_yes) mpfi_d_div(*mpfi_t_obj, SvNV(b), *a);
       else mpfi_div_d(*mpfi_t_obj, *a, SvNV(b));
       return obj_ref;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("%s", "Invalid string supplied to Math::MPFI::overload_div");
       if(third == &PL_sv_yes) mpfi_fr_div(*mpfi_t_obj, t, *a);
       else mpfi_div_fr(*mpfi_t_obj, *a, t);
       mpfr_clear(t);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_div(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return obj_ref;
         }
       }

     croak("%s", "Invalid argument supplied to Math::MPFI::overload_div");
}

SV * overload_add_eq(SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_add_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_add_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_add_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_add_eq");
       }
       mpfi_add_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_add(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);     
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_add_eq");
}

SV * overload_mul_eq(SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_mul_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_mul_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_mul_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_mul_eq");
       }
       mpfi_mul_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_mul(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);     
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_mul_eq");
}

SV * overload_sub_eq(SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_sub_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_sub_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_sub_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_sub_eq");
       }
       mpfi_sub_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_sub(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);     
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_sub_eq");
}

SV * overload_div_eq(SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifndef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfi_div_ui(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvUV(b));
       return a;
       }

     if(SvIOK(b)) {
       mpfi_div_si(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvIV(b));
       return a;
       }
#else
     if(SvUOK(b)) {
       mpfr_init(t);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(SvIOK(b)) {
       mpfr_init(t);
       mpfr_set_sj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }
#endif

#ifndef USE_LONG_DOUBLE
     if(SvNOK(b)) {
       mpfi_div_d(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), SvNV(b));
       return a;
       }
#else
     if(SvNOK(b)) {
       mpfr_init_set_ld(t, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
     }
#endif

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_inc(a);
         croak("%s", "Invalid string supplied to Math::MPFI::overload_div_eq");
       }
       mpfi_div_fr(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), t);
       mpfr_clear(t);
       return a;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_div(*(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         return a;
         }
       }

     SvREFCNT_dec(a);     
     croak("%s", "Invalid argument supplied to Math::MPFI::overload_div_eq");
}

SV * overload_sqrt(mpfi_t * p, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in overload_sqrt function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_sqrt(*mpfi_t_obj, *p);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfi_get_version() {
     return newSVpv(mpfi_get_version(), 0);
}

SV * Rmpfi_const_catalan(mpfi_t * rop) {
     return newSViv(mpfi_const_catalan(*rop));
}

SV * Rmpfi_cbrt(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cbrt(*rop, *op));
}

SV * Rmpfi_sec(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sec(*rop, *op));
}

SV * Rmpfi_csc(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_csc(*rop, *op));
}

SV * Rmpfi_cot(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_cot(*rop, *op));
}

SV * Rmpfi_sech(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_sech(*rop, *op));
}

SV * Rmpfi_csch(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_csch(*rop, *op));
}

SV * Rmpfi_coth(mpfi_t * rop, mpfi_t * op) {
     return newSViv(mpfi_coth(*rop, *op));
}

SV * Rmpfi_atan2(mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_atan2(*rop, *op1, *op2));
}

SV * Rmpfi_hypot(mpfi_t * rop, mpfi_t * op1, mpfi_t * op2) {
     return newSViv(mpfi_hypot(*rop, *op1, *op2));
}

void Rmpfi_urandom(mpfr_t * rop, mpfi_t * op, gmp_randstate_t * state) {
     mpfi_urandom(*rop, *op, *state);
}

SV * overload_true(mpfi_t * op, SV * second, SV * third) {
     if(mpfi_is_zero(*op)) return newSViv(0);
     if(mpfi_nan_p(*op)) return newSViv(0);
     return newSViv(1);
}

SV * overload_not(mpfi_t * op, SV * second, SV * third) {
     if(mpfi_is_zero(*op)) return newSViv(1);
     if(mpfi_nan_p(*op)) return newSViv(1);
     return newSViv(0);
}
     
SV * overload_abs(mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_abs function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_abs(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_sin(mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_sin function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_sin(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_cos(mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_cos function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_cos(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_log(mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_log function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_log(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_exp(mpfi_t * op, SV * second, SV * third) {
     mpfi_t * mpfi_t_obj;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in Rmpfi_exp function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

     mpfi_exp(*mpfi_t_obj, *op);
     sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_atan2(mpfi_t * a, SV * b, SV * third) {
     mpfi_t * mpfi_t_obj;
     mpfr_t tr;
     SV * obj_ref, * obj;

     New(1, mpfi_t_obj, 1, mpfi_t);
     if(mpfi_t_obj == NULL) croak("Failed to allocate memory in overload_atan2 function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFI");
     mpfi_init(*mpfi_t_obj);

#ifdef USE_64_BIT_INT
     if(SvUOK(b)) {
       mpfr_init(tr);
       mpfr_set_uj(tr, SvUV(b), __gmpfr_default_rounding_mode);
       mpfi_set_fr(*mpfi_t_obj, tr);
       mpfr_clear(tr);
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfr_init(tr);
       mpfr_set_sj(tr, SvIV(b), __gmpfr_default_rounding_mode);
       mpfi_set_fr(*mpfi_t_obj, tr);
       mpfr_clear(tr);
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }
#else
     if(SvUOK(b)) {
       mpfi_set_ui(*mpfi_t_obj, SvUV(b));
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(SvIOK(b)) {
       mpfi_set_si(*mpfi_t_obj, SvIV(b));
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }
#endif

     if(SvNOK(b)) {
#ifdef USE_LONG_DOUBLE
       mpfr_init_set_ld(tr, SvNV(b), __gmpfr_default_rounding_mode);
       mpfi_set_fr(*mpfi_t_obj, tr);
       mpfr_clear(tr);
#else
       mpfi_set_d(*mpfi_t_obj, SvNV(b));
#endif
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(SvPOK(b)) {
       if(mpfi_set_str(*mpfi_t_obj, SvPV_nolen(b), 10))
         croak("Invalid string supplied to Math::MPFI::overload_atan2");
       if(third == &PL_sv_yes){
         mpfi_atan2(*mpfi_t_obj, *mpfi_t_obj, *a);
         }
       else {
         mpfi_atan2(*mpfi_t_obj, *a, *mpfi_t_obj);
         }
       sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::MPFI")) {
         mpfi_atan2(*mpfi_t_obj, *a, *(INT2PTR(mpfi_t *, SvIV(SvRV(b)))));
         sv_setiv(obj, INT2PTR(IV,mpfi_t_obj));
         SvREADONLY_on(obj);
         return obj_ref;
         }
       }

     croak("Invalid argument supplied to Math::MPFI::overload_atan2 function");
}
MODULE = Math::MPFI	PACKAGE = Math::MPFI	

PROTOTYPES: DISABLE


int
_has_inttypes ()

int
_has_longlong ()

int
_has_longdouble ()

SV *
RMPFI_BOTH_ARE_EXACT (ret)
	int	ret

SV *
RMPFI_LEFT_IS_INEXACT (ret)
	int	ret

SV *
RMPFI_RIGHT_IS_INEXACT (ret)
	int	ret

SV *
RMPFI_BOTH_ARE_INEXACT (ret)
	int	ret

void
_Rmpfi_set_default_prec (p)
	SV *	p
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	_Rmpfi_set_default_prec(p);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_default_prec ()

void
Rmpfi_set_prec (op, prec)
	mpfi_t *	op
	SV *	prec
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_set_prec(op, prec);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_prec (op)
	mpfi_t *	op

SV *
Rmpfi_round_prec (op, prec)
	mpfi_t *	op
	SV *	prec

SV *
Rmpfi_init ()

SV *
Rmpfi_init_nobless ()

SV *
Rmpfi_init2 (prec)
	SV *	prec

SV *
Rmpfi_init2_nobless (prec)
	SV *	prec

void
DESTROY (p)
	mpfi_t *	p
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	DESTROY(p);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_clear (p)
	mpfi_t *	p
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_clear(p);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_set (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_set_ui (rop, op)
	mpfi_t *	rop
	SV *	op

SV *
Rmpfi_set_si (rop, op)
	mpfi_t *	rop
	SV *	op

SV *
Rmpfi_set_d (rop, op)
	mpfi_t *	rop
	SV *	op

SV *
Rmpfi_set_z (rop, op)
	mpfi_t *	rop
	mpz_t *	op

SV *
Rmpfi_set_q (rop, op)
	mpfi_t *	rop
	mpq_t *	op

SV *
Rmpfi_set_fr (rop, op)
	mpfi_t *	rop
	mpfr_t *	op

SV *
Rmpfi_set_str (rop, s, base)
	mpfi_t *	rop
	SV *	s
	SV *	base

void
Rmpfi_swap (x, y)
	mpfi_t *	x
	mpfi_t *	y
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_swap(x, y);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set (q)
	mpfi_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_ui (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_ui(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_si (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_si(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_d (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_d(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_z (q)
	mpz_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_z(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_q (q)
	mpq_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_q(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_fr (q)
	mpfr_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_fr(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_str (q, base)
	SV *	q
	SV *	base
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_str(q, base);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_nobless (q)
	mpfi_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_nobless(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_ui_nobless (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_ui_nobless(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_si_nobless (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_si_nobless(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_d_nobless (q)
	SV *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_d_nobless(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_z_nobless (q)
	mpz_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_z_nobless(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_q_nobless (q)
	mpq_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_q_nobless(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_fr_nobless (q)
	mpfr_t *	q
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_fr_nobless(q);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_init_set_str_nobless (q, base)
	SV *	q
	SV *	base
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_init_set_str_nobless(q, base);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_diam_abs (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

SV *
Rmpfi_diam_rel (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

SV *
Rmpfi_diam (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

SV *
Rmpfi_mag (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

SV *
Rmpfi_mig (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

SV *
Rmpfi_mid (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

void
Rmpfi_alea (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_alea(rop, op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_d (op)
	mpfi_t *	op

void
Rmpfi_get_fr (rop, op)
	mpfr_t *	rop
	mpfi_t *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_get_fr(rop, op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_add (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_add_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_add_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_add_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_add_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2

SV *
Rmpfi_add_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2

SV *
Rmpfi_add_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2

SV *
Rmpfi_sub (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_sub_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_d_sub (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2

SV *
Rmpfi_sub_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_ui_sub (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2

SV *
Rmpfi_sub_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_si_sub (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2

SV *
Rmpfi_sub_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2

SV *
Rmpfi_z_sub (rop, op1, op2)
	mpfi_t *	rop
	mpz_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_sub_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2

SV *
Rmpfi_q_sub (rop, op1, op2)
	mpfi_t *	rop
	mpq_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_sub_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2

SV *
Rmpfi_fr_sub (rop, op1, op2)
	mpfi_t *	rop
	mpfr_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_mul (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_mul_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_mul_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_mul_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_mul_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2

SV *
Rmpfi_mul_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2

SV *
Rmpfi_mul_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2

SV *
Rmpfi_div (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_div_d (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_d_div (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2

SV *
Rmpfi_div_ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_ui_div (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2

SV *
Rmpfi_div_si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_si_div (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	mpfi_t *	op2

SV *
Rmpfi_div_z (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpz_t *	op2

SV *
Rmpfi_z_div (rop, op1, op2)
	mpfi_t *	rop
	mpz_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_div_q (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpq_t *	op2

SV *
Rmpfi_q_div (rop, op1, op2)
	mpfi_t *	rop
	mpq_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_div_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfr_t *	op2

SV *
Rmpfi_fr_div (rop, op1, op2)
	mpfi_t *	rop
	mpfr_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_neg (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_sqr (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_inv (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_sqrt (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_abs (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_mul_2exp (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_mul_2ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_mul_2si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_div_2exp (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_div_2ui (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_div_2si (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_log (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_exp (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_exp2 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_cos (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_sin (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_tan (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_acos (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_asin (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_atan (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_cosh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_sinh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_tanh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_acosh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_asinh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_atanh (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_log1p (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_expm1 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_log2 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_log10 (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_const_log2 (op)
	mpfi_t *	op

SV *
Rmpfi_const_pi (op)
	mpfi_t *	op

SV *
Rmpfi_const_euler (op)
	mpfi_t *	op

SV *
Rmpfi_cmp (op1, op2)
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_cmp_d (op1, op2)
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_cmp_ui (op1, op2)
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_cmp_si (op1, op2)
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_cmp_z (op1, op2)
	mpfi_t *	op1
	mpz_t *	op2

SV *
Rmpfi_cmp_q (op1, op2)
	mpfi_t *	op1
	mpq_t *	op2

SV *
Rmpfi_cmp_fr (op1, op2)
	mpfi_t *	op1
	mpfr_t *	op2

SV *
Rmpfi_is_pos (op)
	mpfi_t *	op

SV *
Rmpfi_is_strictly_pos (op)
	mpfi_t *	op

SV *
Rmpfi_is_nonneg (op)
	mpfi_t *	op

SV *
Rmpfi_is_neg (op)
	mpfi_t *	op

SV *
Rmpfi_is_strictly_neg (op)
	mpfi_t *	op

SV *
Rmpfi_is_nonpos (op)
	mpfi_t *	op

SV *
Rmpfi_is_zero (op)
	mpfi_t *	op

SV *
Rmpfi_has_zero (op)
	mpfi_t *	op

SV *
Rmpfi_nan_p (op)
	mpfi_t *	op

SV *
Rmpfi_inf_p (op)
	mpfi_t *	op

SV *
Rmpfi_bounded_p (op)
	mpfi_t *	op

SV *
_Rmpfi_out_str (stream, base, dig, p)
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p

SV *
_Rmpfi_out_strS (stream, base, dig, p, suff)
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p
	SV *	suff

SV *
_Rmpfi_out_strP (pre, stream, base, dig, p)
	SV *	pre
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p

SV *
_Rmpfi_out_strPS (pre, stream, base, dig, p, suff)
	SV *	pre
	FILE *	stream
	SV *	base
	SV *	dig
	mpfi_t *	p
	SV *	suff

SV *
Rmpfi_inp_str (p, stream, base)
	mpfi_t *	p
	FILE *	stream
	SV *	base

void
Rmpfi_print_binary (op)
	mpfi_t *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_print_binary(op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_get_left (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

SV *
Rmpfi_get_right (rop, op)
	mpfr_t *	rop
	mpfi_t *	op

SV *
Rmpfi_revert_if_needed (op)
	mpfi_t *	op

SV *
Rmpfi_put (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_put_d (rop, op)
	mpfi_t *	rop
	SV *	op

SV *
Rmpfi_put_ui (rop, op)
	mpfi_t *	rop
	SV *	op

SV *
Rmpfi_put_si (rop, op)
	mpfi_t *	rop
	SV *	op

SV *
Rmpfi_put_z (rop, op)
	mpfi_t *	rop
	mpz_t *	op

SV *
Rmpfi_put_q (rop, op)
	mpfi_t *	rop
	mpq_t *	op

SV *
Rmpfi_put_fr (rop, op)
	mpfi_t *	rop
	mpfr_t *	op

SV *
Rmpfi_interv_d (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	SV *	op2

SV *
Rmpfi_interv_ui (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	SV *	op2

SV *
Rmpfi_interv_si (rop, op1, op2)
	mpfi_t *	rop
	SV *	op1
	SV *	op2

SV *
Rmpfi_interv_z (rop, op1, op2)
	mpfi_t *	rop
	mpz_t *	op1
	mpz_t *	op2

SV *
Rmpfi_interv_q (rop, op1, op2)
	mpfi_t *	rop
	mpq_t *	op1
	mpq_t *	op2

SV *
Rmpfi_interv_fr (rop, op1, op2)
	mpfi_t *	rop
	mpfr_t *	op1
	mpfr_t *	op2

SV *
Rmpfi_is_strictly_inside (op1, op2)
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_is_inside (op1, op2)
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_is_inside_d (op2, op1)
	SV *	op2
	mpfi_t *	op1

SV *
Rmpfi_is_inside_ui (op2, op1)
	SV *	op2
	mpfi_t *	op1

SV *
Rmpfi_is_inside_si (op2, op1)
	SV *	op2
	mpfi_t *	op1

SV *
Rmpfi_is_inside_z (op2, op1)
	mpz_t *	op2
	mpfi_t *	op1

SV *
Rmpfi_is_inside_q (op2, op1)
	mpq_t *	op2
	mpfi_t *	op1

SV *
Rmpfi_is_inside_fr (op2, op1)
	mpfr_t *	op2
	mpfi_t *	op1

SV *
Rmpfi_is_empty (op)
	mpfi_t *	op

SV *
Rmpfi_intersect (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_union (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_increase (rop, op)
	mpfi_t *	rop
	mpfr_t *	op

SV *
Rmpfi_blow (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	SV *	op2

SV *
Rmpfi_bisect (rop1, rop2, op)
	mpfi_t *	rop1
	mpfi_t *	rop2
	mpfi_t *	op

void
RMPFI_ERROR (msg)
	SV *	msg
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	RMPFI_ERROR(msg);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
Rmpfi_is_error ()

void
Rmpfi_set_error (op)
	SV *	op
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_set_error(op);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

void
Rmpfi_reset_error ()
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_reset_error();
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_itsa (a)
	SV *	a

SV *
gmp_v ()

SV *
mpfr_v ()

SV *
overload_gte (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_lte (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_gt (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_lt (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_equiv (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_add (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_mul (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_sub (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_div (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

SV *
overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
overload_sqrt (p, second, third)
	mpfi_t *	p
	SV *	second
	SV *	third

SV *
Rmpfi_get_version ()

SV *
Rmpfi_const_catalan (rop)
	mpfi_t *	rop

SV *
Rmpfi_cbrt (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_sec (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_csc (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_cot (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_sech (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_csch (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_coth (rop, op)
	mpfi_t *	rop
	mpfi_t *	op

SV *
Rmpfi_atan2 (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

SV *
Rmpfi_hypot (rop, op1, op2)
	mpfi_t *	rop
	mpfi_t *	op1
	mpfi_t *	op2

void
Rmpfi_urandom (rop, op, state)
	mpfr_t *	rop
	mpfi_t *	op
	gmp_randstate_t *	state
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	Rmpfi_urandom(rop, op, state);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
overload_true (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third

SV *
overload_not (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third

SV *
overload_abs (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third

SV *
overload_sin (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third

SV *
overload_cos (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third

SV *
overload_log (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third

SV *
overload_exp (op, second, third)
	mpfi_t *	op
	SV *	second
	SV *	third

SV *
overload_atan2 (a, b, third)
	mpfi_t *	a
	SV *	b
	SV *	third

