from toml import load
from os.path import join as pjoin

instructions = load(pjoin(".", "docs", "instructions.toml"))

define_list = []

for inst in instructions.keys():
    bcode = instructions[inst]["bcode"]

    try:
        arg_infos = instructions[inst]["arg_kinds"]
    except KeyError:
        define_list.append(
            "".join([
                f"`define {inst}".ljust(20, " "),
                f"16'h{hex(bcode)[2:].upper()}\n"
            ])
        )
    else:
        for arg_info in arg_infos:
            if len(arg_info) == instructions[inst]["arg_num"]:
                define_list.append(
                    "".join([
                        f"`define {inst}".ljust(20, " "),
                        f"16'h{hex(bcode)[2:].upper()}\n"
                    ])
                )
            else:
                add_name_temp = ""
                for arg_index in range(instructions[inst]["arg_num"]):
                    add_name_temp += arg_info[arg_index][0].upper()
                define_list.append(
                    "".join([
                        f"`define {inst}_{add_name_temp}".ljust(20, " "),
                        f"16'h{hex(int(arg_info[-1]) + bcode)[2:].upper()}\n"
                    ])
                )


with open(pjoin(".", "header", "instructions.vh"), "a+") as inst_vh:
    inst_vh.seek(0)
    inst_vh.truncate(0)
    inst_vh.seek(0)
    inst_vh.writelines(define_list)
