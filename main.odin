package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strings"
import "core:strconv"

main :: proc() {
    do_day( 1, day01, "distance", "similarity")
    do_day( 2, day02, "safe reports", "safe reports with tolerance")
    do_day( 3, day03, "uncorrupted mul instructions", "enabled mul instructions")
    do_day( 4, day04, "XMAS count", "X-MAS count")
    do_day( 5, day05, "correct update middle page number sum", "fixed incorrect update middle page number sum", true, false)
    do_day( 6, day06, "visited positions", "obstruction positions causing a loop", true, false)
    do_day( 7, day07, "total calibration result", "total calibration result with concatenation")
    do_day( 8, day08, "antinode locations", "antinode locations with resonant harmonics")
    do_day( 9, day09, "", "", false, false)
    do_day(10, day10, "", "", false, false)
    do_day(11, day11, "", "", false, false)
    do_day(12, day12, "", "", false, false)
    do_day(13, day13, "", "", false, false)
    do_day(14, day14, "", "", false, false)
    do_day(15, day15, "", "", false, false)
    do_day(16, day16, "", "", false, false)
    do_day(17, day17, "", "", false, false)
    do_day(18, day18, "", "", false, false)
    do_day(19, day19, "", "", false, false)
    do_day(20, day20, "", "", false, false)
    do_day(21, day21, "", "", false, false)
    do_day(22, day22, "", "", false, false)
    do_day(23, day23, "", "", false, false)
    do_day(24, day24, "", "", false, false)
    do_day(25, day25, "", "", false, false)

}

day25 :: day0X
day24 :: day0X
day23 :: day0X
day22 :: day0X
day21 :: day0X
day20 :: day0X
day19 :: day0X
day18 :: day0X
day17 :: day0X
day16 :: day0X
day15 :: day0X
day14 :: day0X
day13 :: day0X
day12 :: day0X
day11 :: day0X
day10 :: day0X
day09 :: day0X

day0X :: proc(path, test_path: string) -> (part1, part2: i64) {
    line, ok := read_file(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)

    return
}

day08 :: proc(path, test_path: string) -> (unique_antinode_locations, unique_antinode_locations_with_resonant_harmonics: i64) {
    lines, ok := read_lines(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)
    
    Antenna :: rune
    Position :: [2]int
    antennas: map[Antenna][dynamic]Position

    size := Position{len(lines), len(lines[0])}
    for line, row in lines {
        for frequency, col in line {
            if frequency != '.' && frequency != '#' {
                if position, ok := &antennas[frequency]; ok {
                    append(position, [2]int{row, col})
                } else {
                    antennas[frequency] = { {row, col} }
                }
            }
        }
    }

    Antinodes :: map[Position]b32
    antinodes: map[Antenna]Antinodes
    antinodes_with_resonant_harmonics: map[Antenna]Antinodes
    for frequency, positions in antennas {
        antinodes[frequency] = {}
        nodes := &antinodes[frequency]
        nodes^ = {}
        
        antinodes_with_resonant_harmonics[frequency] = {}
        nodes_with_resonant_harmonics := &antinodes_with_resonant_harmonics[frequency]
        nodes_with_resonant_harmonics^ = {}

        for p1, i in positions {
            for p2 in positions[i+1:] {
                delta := p1 - p2

                in_bounds :: proc(size, point: Position) -> b32 {
                    return point.x < size.x && point.x >= 0 && point.y < size.y && point.y >= 0
                }
                
                a_without_resonant_harmonics := p1 + delta
                if in_bounds(size, a_without_resonant_harmonics) {
                    nodes[a_without_resonant_harmonics] = true
                }
                b_without_resonant_harmonics := p2 - delta
                if in_bounds(size, b_without_resonant_harmonics) {
                    nodes[b_without_resonant_harmonics] = true
                }
                
                for a := p2 + delta; in_bounds(size, a); a += delta {
                    nodes_with_resonant_harmonics[a] = true
                }
                for b := p1 - delta; in_bounds(size, b); b -= delta {
                    nodes_with_resonant_harmonics[b] = true
                }
            }
        }
    }

    all_antinodes: Antinodes
    for _, nodes in antinodes {
        for node, _ in nodes {
            all_antinodes[node] = true
        }
    }
    all_antinodes_with_resonant_harmonics: Antinodes
    for _, nodes in antinodes_with_resonant_harmonics {
        for node, _ in nodes {
            all_antinodes_with_resonant_harmonics[node] = true
        }
    }


    return auto_cast len(all_antinodes), auto_cast len(all_antinodes_with_resonant_harmonics)
}

day07 :: proc(path, test_path: string) -> (total_calibration_result, total_calibration_result_with_concatenation: i64) {
    lines, ok := read_lines(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)
    
    concat :: proc(a, b:i64) -> (result: i64) {
        digits_in_b := 1 if b < 2 else math.log10(f64(b))
        result = a
        for _ in 0..<digits_in_b {
            result *= 10
        }
        result += b
        return 
    }

    next_operation :: proc(numbers: [dynamic]i64, test_value: i64, current:i64, index:i64, allow_concatenation: b32 ) -> b32 {
        if index == auto_cast len(numbers) && current == test_value {
            return true
        } else if current > test_value {
            return false
        } else {
            if index == auto_cast len(numbers) {
                return false
            } else {
                number := numbers[index]
                if next_operation(numbers, test_value, current * number, index+1, allow_concatenation) {
                    return true
                }
                if next_operation(numbers, test_value, current + number, index+1, allow_concatenation) {
                    return true
                }
                if allow_concatenation && next_operation(numbers, test_value, concat(current, number), index+1, allow_concatenation) {
                    return true
                }
                return false
            }

        }
    }

    for line in lines {
        rest := line
        test_value: i64
        numbers: [dynamic]i64
        test_value, rest = chop_number(rest)
        ok: b32
        if ok, rest = expect(rest, ":"); ok {
            for rest != "" {
                num: i64
                num, rest = chop_number(rest)
                append(&numbers, num)
            }
        }

        if next_operation(numbers, test_value, numbers[0], 1, false) {
            total_calibration_result += test_value
        }
        if next_operation(numbers, test_value, numbers[0], 1, true) {
            total_calibration_result_with_concatenation += test_value
        }
    }

    return
}

day06 :: proc(path, test_path: string) -> (visited_positions, loop_possibilities: i64) {
    line, ok := read_file(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)

    CellFlag :: enum{ Right, Up, Left, Down, Obstacle } 
    Cell :: bit_set[ CellFlag ]
    GuardState :: enum { Alive, OffBoard, Looped }
    Position :: struct{
        pos:[2]int, 
        dir: CellFlag
    }
    Guard :: struct {
        state: GuardState,
        using position: Position,
        start: [2]int,
        start_dir: CellFlag,
        history: map[Position]b32,
    }

    cols: int
    for r, i in line {
        if r == '\n' {
            cols = i
            break
        }
    }
    rows := len(line) / cols
    grid := make([]Cell, rows * cols)
    phantom_spawns := make([]Cell, rows * cols)
    
    
    guard: Guard
    {
        row, col: int
        for r, i in line {
            switch r {
            case '#': grid[row * cols + col] = {.Obstacle}
            case '^', 'v', '<', '>':
                guard = {
                    pos = {row, col},
                    start = {row, col},
                }
                switch r {
                case '^': guard.dir = .Up
                case 'v': guard.dir = .Down
                case '<': guard.dir = .Left
                case '>': guard.dir = .Right
                }
                guard.start_dir = guard.dir
            case '\n':
                row += 1
                col = 0
                continue
            }

            col += 1
        }
    }

    in_bounds :: #force_inline  proc(pos:[2] int, rows, cols: int) -> b32 {
        return pos.x >= 0 && pos.x < rows && pos.y >= 0 && pos.y < cols
    }

    turn_right :: #force_inline proc(dir: CellFlag) -> (result: CellFlag) {
        #partial switch dir {
            case .Right: result = .Down
            case .Up:    result = .Right
            case .Left:  result = .Up
            case .Down:  result = .Left
        }
        return result
    }

    print_grid :: proc(rows, cols: int, guard: ^Guard, grid:[]Cell, phantoms:[dynamic]Guard) {
        when true {
            for row in 0 ..< rows {
                for col in 0 ..< cols {
                    phantom_present: b32
                    for phantom in phantoms {
                        if phantom.state == .Looped && row == phantom.start.x && col == phantom.start.y {
                            phantom_present = true
                            break
                        }
                    }

                    if phantom_present {
                        fmt.print('"')
                    } else if row == guard.pos.x && col == guard.pos.y {
                        #partial switch guard.dir {
                        case .Up:    fmt.print('^')
                        case .Down:  fmt.print('v')
                        case .Left:  fmt.print('<')
                        case .Right: fmt.print('>')
                        }
                    } else {
                        switch grid[row * cols + col] {
                        case {}: fmt.print(".")
                        case {.Obstacle}: fmt.print("#")
                        case: fmt.print("X")
                        }
                    }
                }
                fmt.println()
            }
            fmt.println()
            fmt.println("--------------------")
            fmt.println()
        }
    }
    
    update_guard :: #force_inline proc(grid: []Cell, rows, cols: int, guard: ^Guard, is_phantom: b32) {
        delta: [2]int
        #partial switch guard.dir {
          case .Right: delta = {  0,  1 }
          case .Up:    delta = { -1,  0 }
          case .Left:  delta = {  0, -1 }
          case .Down:  delta = {  1,  0 }
        }
        step := guard.pos + delta
        
        if is_phantom {
            looped: b32
            if guard.pos == guard.start && turn_right(guard.dir) == guard.start_dir {
                looped = true
            }
            if guard.position in guard.history {
                looped = true
            }
            if looped {
                guard.pos = step
                guard.state = .Looped
                return
            }
        }
        guard.history[ guard.position ] = true

        if !in_bounds(step, rows, cols) {
            guard.pos = step
            guard.state = .OffBoard
        } else {
            if grid[step.x * cols + step.y] == {.Obstacle} {
                guard.dir = turn_right(guard.dir)
            } else {
                guard.pos = step
            }

        }
    }

    phantoms: [dynamic]Guard
    for {
        if guard.state == .Alive {
            position := &grid[guard.pos.x * cols + guard.pos.y]
            Unvisited  :: Cell{}
            if position^ == Unvisited {
                visited_positions += 1
            }

            // TODO(viktor): spawned phantom revisited is also a die moment
            prev := guard
            update_guard(grid, rows, cols, &guard, false)
            if prev.dir not_in position {
                if guard.pos != guard.start {
                    spawn_point := &phantom_spawns[prev.pos.x * cols + prev.pos.y]
                    phantom_dir := turn_right(prev.dir)
                    if phantom_dir not_in spawn_point {
                        phantom := Guard{
                            pos        = prev.pos,
                            dir        = phantom_dir,
                            start      = prev.pos,
                            start_dir  = phantom_dir,
                        }
                        spawn_point^ += { phantom_dir }
                        
                        append(&phantoms, phantom)
                    }
                }
                position^ += { prev.dir }
            }
        }
        // TODO(viktor): IMPORTANT(viktor): confirm that no phantom path is counted twice
        alive_count := guard.state == .Alive ? 1 : 0
        #reverse for &it, it_index in phantoms {
            if it.state == .Alive {
                alive_count += 1
                update_guard(grid, rows, cols, &it, true)
                if it.state == .Looped {
                    loop_possibilities += 1
                }
            }
        }
        
        // print_grid(rows, cols, &guard, grid, phantoms)
        if alive_count == 0 {
            break
        }

    }


    return
}

day05 :: proc(path, test_path: string) -> (correct_middle_page_sum, incorrect_middle_page_sum: i64) {
    lines, ok := read_lines(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)

    PageOrdering :: map[i64]^PageOrdering // befores:  [before]link
    orderings: map[i64]PageOrdering       // ordeing: [after]befores
    
    Update :: [dynamic]i64
    updates: [dynamic]Update

    // ---------------------- PARSING
    parse_orderings := true
    for line in lines {
        if line == "" {
            parse_orderings = false
            continue
        }

        if parse_orderings {
            rest := line
            before, after: i64
            before, rest = chop_number(rest)
            rest = eat(rest, "|")
            after, rest = chop_number(rest)

            if ordering, ok := &orderings[after]; ok {
                ordering[before] = nil
            } else {
                orderings[after] = PageOrdering{ before = nil }
            }
        } else {
            rest := line
            update: Update
            for rest != "" {
                a: i64
                a, rest = chop_number(rest)
                append(&update, a)
                if rest == "" {
                    break
                }
                rest = eat(rest, ",")
            }
            append(&updates, update)
        }
    }
    
    // ---------------------- Build a "tree"
    // for _, ordering in orderings {
    //     for before, &link in ordering {
    //         if linked, ok := &orderings[before]; ok {
    //             link = linked
    //         }
    //     }
    // }
    // fmt.printfln("%#v", orderings)

    // ---------------------- EVALUATING
    for update in updates {
        
        is_valid := true
        for page, page_index in update {
            if ordering, ok := orderings[page]; ok {
                for page_after in update[page_index:] {
                    if page_after in ordering {
                        is_valid = false
                        break
                    }
                }
            }
        }

        if is_valid {
            middle_page_number := update[len(update) / 2]
            correct_middle_page_sum += middle_page_number
        } else {
            // TODO(viktor): sort
            // fix the update ordering
            

            middle_page_number := update[len(update) / 2]
            incorrect_middle_page_sum += middle_page_number
        }
    }

    return
}

day04 :: proc(path, test_path: string) -> (xmas_count, x_mas_count: i64) {
    line, ok := read_file(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)
    
    width: i64
    for r, i in line {
        if r == '\n' && width == 0 {
            width = auto_cast i+1
        }
    }
    
    length := i64(len(line))
    for i in 0 ..< length {
        before := xmas_count
        is_xmas :: #force_inline proc(text: string, p0, p1, p2, p3: i64) -> (result: b32) {
            max_index := max(p0, p1, p2, p3)
            if max_index < auto_cast len(text) {
                if  text[p0] == 'X' &&
                    text[p1] == 'M' &&
                    text[p2] == 'A' &&
                    text[p3] == 'S' {
                    result = true
                }

                if  text[p0] == 'S' &&
                    text[p1] == 'A' &&
                    text[p2] == 'M' &&
                    text[p3] == 'X' {
                    result = true
                }
            }
            return result
        }

        if is_xmas(line, i+0, i+1, i+2, i+3) { // Horizontal -
            xmas_count += 1
        }

        if is_xmas(line, i+width*0, i+width*1, i+width*2, i+width*3) { // Vertical |
            xmas_count += 1
        }
        
        if is_xmas(line, i+0+width*0, i+1+width*1, i+2+width*2, i+3+width*3) { // Diagonal \
            xmas_count += 1
        }
        
        if is_xmas(line, i-0+width*0, i-1+width*1, i-2+width*2, i-3+width*3) { // Diagonal /
            xmas_count += 1
        }
        
        is_x_mas :: #force_inline proc(text: string, p0: i64, width: i64) -> (result: b32) {
            p1 := p0 + width*0 + 2
            p2 := p0 + width*1 + 1
            p3 := p0 + width*2 + 0
            p4 := p0 + width*2 + 2
            max_index := p4

            if max_index < auto_cast len(text) {
                if  text[p0] == 'M' &&
                    text[p1] == 'S' &&
                    text[p2] == 'A' &&
                    text[p3] == 'M' &&
                    text[p4] == 'S' {
                    result = true
                }
                if  text[p0] == 'M' &&
                    text[p1] == 'M' &&
                    text[p2] == 'A' &&
                    text[p3] == 'S' &&
                    text[p4] == 'S' {
                    result = true
                }
                if  text[p0] == 'S' &&
                    text[p1] == 'S' &&
                    text[p2] == 'A' &&
                    text[p3] == 'M' &&
                    text[p4] == 'M' {
                    result = true
                }
                if  text[p0] == 'S' &&
                    text[p1] == 'M' &&
                    text[p2] == 'A' &&
                    text[p3] == 'S' &&
                    text[p4] == 'M' {
                    result = true
                }

            }
            return result
        }


        if is_x_mas(line, i, width) {
            x_mas_count += 1
        }
    }

    return
}

day03 :: proc(path, test_path: string) -> (uncorrupted_sum, enabled_uncorrupted_sum: i64) {
    line, ok := read_file(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)

    enabled: b32 = true
    rest:= line
    for rest != "" {
        a,b: i64
        
        mul_ok, mul_cut := find(rest, "mul")
        do_ok, do_cut := find(rest, "do")
        if mul_ok && do_ok {
            if mul_cut < do_cut {
                do_ok = false
            } else {
                mul_ok = false
            }
        } 
        
        if mul_ok {
            rest = rest[mul_cut:]
            if ok, rest = expect(rest, "("); ok {
                if ok, a, rest = trim_until_number(rest); ok {
                    if ok, rest = expect(rest, ","); ok {
                        if ok, b, rest = trim_until_number(rest); ok {
                            if ok, rest = expect(rest, ")"); ok {
                                uncorrupted_sum += a*b
                                if enabled {
                                    enabled_uncorrupted_sum += a*b
                                }
                            }
                        }
                    }
                }
            }
        } else if do_ok {
            rest = rest[do_cut:]
            if ok, rest = expect(rest, "n't()"); ok {
                enabled = false
            } else if ok, rest = expect(rest, "()"); ok {
                enabled = true
            }
        } else {
            break
        }
    }

    return
}

day02 :: proc(path, test_path: string) -> (safe_reports, safe_reports_with_dampening: i64) {
    lines, ok := read_lines(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)

    for line, line_index in lines {
        Report :: [dynamic]i64
        chop_report :: proc(view: string) -> (result: Report, rest: string) {
            rest = view
            for rest != "" {
                rest = trim_left(rest)
                r: i64
                r, rest = chop_number(rest)
                append(&result, r)
            }

            return
        }

        report, _ := chop_report(line)

        is_report_safe :: proc(report: Report, skipped_index: i64 = min(i64)) -> (is_safe: b32 = true) {
            descending: b32
            for i in 1..<len(report) {
                if auto_cast i == skipped_index {
                    continue
                }
                last, current := report[i-1], report[i]
                if auto_cast (i-1) == skipped_index {
                    if i == 1 {
                        continue
                    } else {
                        last = report[i-2]
                    }
                }

                if last != current {
                    descending = last > current
                    break
                }
            }

            for i in 1..<len(report) {
                if auto_cast i == skipped_index {
                    continue
                }
                last, current := report[i-1], report[i]
                if auto_cast (i-1) == skipped_index {
                    if i == 1 {
                        continue
                    } else {
                        last = report[i-2]
                    }
                }

                distance: i64
                if descending {
                    distance = last - current
                    is_safe &= last > current
                } else {
                    distance = current - last
                    is_safe &= last < current
                }
                is_safe &= distance >= 1 && distance <= 3 

                if !is_safe {
                    continue
                }
            }

            return
        }

        if is_report_safe(report) {
            safe_reports += 1
            safe_reports_with_dampening += 1
        } else {
            for dampended_index in 0..<len(report) {
                if is_report_safe(report, auto_cast dampended_index) {
                    safe_reports_with_dampening += 1
                    break
                }
            }
        }
    }


    
    return
}

day01 :: proc(path, test_path:string) -> (total_distance, similarity: i64){
    lines, ok := read_lines(path when !ODIN_DEBUG else test_path)
    assert(auto_cast ok)
    
    as, bs: [dynamic]i64
    for line in lines {
        a, b: i64
        rest := line
        a, rest = chop_number(rest)
        b, rest = chop_number(rest)
        
        append(&as, a)
        append(&bs, b)
    }

    slice.sort(as[:])
    slice.sort(bs[:])

    for i in 0..<len(as) {
        distance := abs(as[i] - bs[i])
        total_distance += distance
    }

    a_last, b_count, bi: i64
    for a in as {
        defer a_last = a

        if a_last != a {
            b_count = 0
            for b, i in bs[bi:] {
                if b == a {
                    b_count += 1
                } else if b > a {
                    bi = auto_cast i
                    break
                }
            }
        }

        similarity += a * b_count
    }

    return total_distance, similarity
}

do_day :: proc(num:int, day_func: proc(path, test_path: string) -> (i64, i64), label1, label2: string, solved1 := true, solved2 := true) {
    if day_func != day0X {
        path      := fmt.tprintf("./data/%02d.txt", num)
        test_path := fmt.tprintf("./data/%02d_test.txt", num)
        d01_one, d01_two := day_func(path, test_path)
        fmt.printfln("Day % 2d:", num)
        if !solved1 {
            fmt.print("  TODO:")
        }
        fmt.printfln("  Part 1: %v (%v)", d01_one, label1)
        if !solved2 {
            fmt.print("  TODO:")
        }
        fmt.printfln("  Part 2: %v (%v)", d01_two, label2)
    }
}