package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "base:intrinsics"

kilobytes :: proc(value: $N) -> N where intrinsics.type_is_numeric(N) && size_of(N) == 8 { return value*1024 }
megabytes :: proc(value: $N) -> N where intrinsics.type_is_numeric(N) && size_of(N) == 8 { return kilobytes(value)*1024 }
gigabytes :: proc(value: $N) -> N where intrinsics.type_is_numeric(N) && size_of(N) == 8 { return megabytes(value)*1024 }
terabytes :: proc(value: $N) -> N where intrinsics.type_is_numeric(N) && size_of(N) == 8 { return gigabytes(value)*1024 }

swap :: proc(a, b: ^$T) {
    b^, a^ = a^, b^
}

print_bits :: proc(a: u8) {
	for i:=256; i>0; i >>= 1 {
		fmt.print('1' if a & u8(i) != 0 else '0')
	}
	fmt.println()
}

line_to_numbers :: proc(line:string, separator := ",") -> ([]int) {
	numbers := strings.split(line, separator)
	result := make([]int, len(numbers))
	for n, i in numbers {
		result[i] = strconv.atoi(n)
	}
	return result
}

chop_line :: proc(view: string) -> (result: string, rest:string) {
    cut := 0
    for r, index in view {
        if r == '\n' {
            cut = index
            break
        }
    }

    return view[:cut], view[cut:]
}

trim_left :: proc(view: string) -> (result: string) {
    result = view
    for result != "" && strings.is_space(cast(rune) result[0]) {
        result = result[1:]
    }
    return result
}

chop_number :: proc(view: string) -> (result: i64, rest:string) {
    view := trim_left(view)
    cut := 0
    for r in view {
        if is_numeric(r) {
            cut +=1
        } else {
            break
        }
    }
    
    return cast(i64) strconv.atoi(view[:cut]), view[cut:]
}

trim_until_number :: proc(view: string) -> (ok: b32, chopped: i64, rest: string) {
    for r, r_index in view {
        if is_numeric(r) {
            start:= r_index
            end := start
            for n in view[r_index+1:] {
                if is_numeric(n) {
                    end += 1
                } else {
                    break
                }
            }
            end += 1
            number := view[start:end]
            chopped = auto_cast strconv.atoi(number)
            return true, chopped, view[end:]
        }
    }

    return false, chopped, view
}

eat :: proc(view: string, target: string) -> (rest: string) {
    cut := len(target)
    if view[:cut] == target {
        return view[cut:]
    } else {
        return view
    }
}

expect :: proc(view: string, target: string) -> (ok: b32, rest: string) {
    cut := len(target)
    if view[:cut] == target {
        return true, view[cut:]
    } else {
        return false, view
    }
}

find :: proc(view: string, target: string) -> (ok: b32, index:i32) {
    for r, r_index in view {
        if len(view) - r_index < len(target) {
            break
        }

        if r == cast(rune) target[0] {
            if view[r_index:][:len(target)] == target {
                cut := r_index + len(target)
                return true, auto_cast cut
            }
        }
    }

    return false, 0
}

trim :: proc(view: string, target: string) -> (ok: b32, rest: string) {
    cut: i32
    ok, cut = find(view, target)
    if ok {
        return true, view[cut:]
    } else {
        return false, view
    }
}


is_numeric :: proc(r: rune) -> b32 {
    switch r {
    case '0'..='9': return true
    case:           return false
    }
}

read_file :: proc(file: string) -> (result: string, success: b32) {
	data, ok := os.read_entire_file(file)
	if !ok do return {}, false
	return string(data), true
}

read_lines :: proc(file: string) -> (result: []string, success: b32) {
	data, ok := os.read_entire_file(file)
	if !ok do return nil, false
	return strings.split_lines(string(data)), true
}

index_in_bounds :: #force_inline proc "contextless" (index: int, array:[]$T) -> bool {
	return index >= 0 && index < len(array)
}