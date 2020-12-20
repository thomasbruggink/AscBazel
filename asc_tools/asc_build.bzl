"""
"""

AscBuildFilesInfo = provider("objects")

def _asc_build_impl(ctx):
    main = ctx.attr.main
    compilation_mode = ctx.var["COMPILATION_MODE"]
    source_maps = ctx.attr.sourceMaps
    shrink_level = ctx.attr.shrinkLevel
    output = []
    flags = []
    output_type = ctx.attr.outputType
    output_ext = ctx.attr.outputExt
    runtime = ctx.attr.runtime
    toolchain = ctx.toolchains["//asc_tools:toolchain_type"].toolchain
    input_files = toolchain.node_modules.files.to_list()

    if compilation_mode == "dbg":
        flags.append("-O0")
        flags.append("--debug")
    elif compilation_mode == "opt":
        flags.append("-O3")
        flags.append("--converge")
    else:
        flags.append("-O2")
    flags.append("--shrinkLevel %d" % shrink_level)
    flags.append("--runtime %s" % runtime)
    
    if output_ext == "":
        if output_type == "text":
            output_ext = "wat"
            output_type = "--textFile"
            pass
        elif output_type == "js":
            output_ext = "js"
            output_type = "--jsFile"
            pass
        elif output_type == "idl":
            output_ext = "webidl"
            output_type = "--idlFile"
            pass
        elif output_type == "tsd":
            output_ext = "d.ts"
            output_type = "--tsdFile"
            pass
        else:
            output_ext = "wasm"
            output_type = "--binaryFile"
    else:
        output_type = "--outFile"

    for flag in ctx.attr.flags:
        flags.append(flag)

    main_file = None
    for deps in ctx.attr.srcs:
        for file in deps.files.to_list():
            if file.basename == main:
                main_file = file
            input_files.append(file)

    name = main_file.basename.replace(main_file.extension, "")
    i_file = main_file.path
    str_o_file = "%s%s" % (name, output_ext)
    o_file = ctx.actions.declare_file(str_o_file)
    output.append(o_file)

    if source_maps:
        flags.append("--sourceMap")
        output.append(ctx.actions.declare_file("%s.map" % str_o_file))

    ctx.actions.run(
        outputs = output,
        inputs = input_files,
        executable = toolchain.asc,
        arguments = flags + [output_type, "%s/%s" % (ctx.bin_dir.path, o_file.basename), i_file],
        progress_message = "Compiling %s -> %s" % (i_file, o_file.basename),
    )
    return [
        AscBuildFilesInfo(objects = depset(output)),
        DefaultInfo(files = depset(output)),
    ]

asc_build = rule(
    implementation = _asc_build_impl,
    attrs = {
        "main": attr.string(), 
        "srcs": attr.label_list(allow_files = [".ts"]),
        "flags": attr.string_list(
            doc="Flags to pass to the assemblyscript compiler"
        ),
        "sourceMaps": attr.bool(
            default=False,
            doc='Generate source maps'
        ),
        "shrinkLevel": attr.int(
            default=0,
            doc='Shrink optimization.'
        ),
        "outputType": attr.string(
            default="binary",
            doc="Output type, options are `binary`, `text`, `js`, `idl` and `tsd`"
        ),
        "outputExt": attr.string(
            default="",
            doc="Output extension, if set outputType not used and automatically decided"
        ),
        "runtime": attr.string(
            default="half",
            doc="Runtime, options are `full`, `half`, `stub` and `non`"
        )
    },
    toolchains = ["//asc_tools:toolchain_type"],
)
