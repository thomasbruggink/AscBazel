AscCompilerInfo = provider(
    doc = "Compiler information",
    fields = [
        "node_modules",
        "asc",
    ],
)

def _asc_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        toolchain = AscCompilerInfo(
            node_modules = ctx.attr.node_modules,
            asc = ctx.attr.asc
        ),
    )]

asc_toolchain = rule(
    implementation = _asc_toolchain_impl,
    attrs = {
        "node_modules": attr.label(
            allow_files = True,
            cfg = "host",
            default = "//:node_modules_path",
        ),
        "asc": attr.string(
            default = "node_modules/.bin/asc"
        ),
    },
)
