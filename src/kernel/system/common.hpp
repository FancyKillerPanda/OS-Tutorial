//  ===== Date Created: 21 July, 2021 ===== 

#if !defined(COMMON_HPP)
#define COMMON_HPP

#if !defined(__clang__)
#error Clang is the only compiler supported right now...
#endif

#define UNUSED(x) (void) (x)
#define BREAK_POINT() asm volatile("xchg %%bx, %%bx" ::)

// Common types
using s8 = signed char;
using s16 = short;
using s32 = int;
using s64 = long long;

using u8 = char; // NOTE(fkp): Forced to by unsigned through compiler flags
using u16 = unsigned short;
using u32 = unsigned int;
using u64 = unsigned long long;
using usize = u32;

using f32 = float;
using f64 = double;

#endif
