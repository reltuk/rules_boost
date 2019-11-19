load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

hdrs_patterns = [
    "boost/%s.h",
    "boost/%s_fwd.h",
    "boost/%s.hpp",
    "boost/%s_fwd.hpp",
    "boost/%s/**/*.hpp",
    "boost/%s/**/*.ipp",
    "boost/%s/**/*.h",
    "libs/%s/src/*.ipp",
]

srcs_patterns = [
    "libs/%s/src/*.cpp",
    "libs/%s/src/*.hpp",
]

# Building boost results in many warnings for unused values. Downstream users
# won't be interested, so just disable the warning.
default_copts = select({
    "@boost//:linux": ["-Wno-unused-value"],
    "//conditions:default": [],
})

default_defines = select({
    ":windows_x86_64": ["BOOST_ALL_NO_LIB"],  # Turn auto_link off in MSVC compiler
    "//conditions:default": [],
})

def srcs_list(library_name, exclude):
    return native.glob(
        [p % (library_name,) for p in srcs_patterns],
        exclude = exclude,
    )

def hdr_list(library_name, exclude = []):
    return native.glob([p % (library_name,) for p in hdrs_patterns], exclude = exclude)

def boost_library(
        name,
        boost_name = None,
        defines = None,
        hdrs = None,
        srcs = None,
        deps = None,
        copts = None,
        exclude_src = [],
        exclude_hdr = [],
        linkopts = None,
        linkstatic = None,
        visibility = ["//visibility:public"]):
    if boost_name == None:
        boost_name = name

    if defines == None:
        defines = []

    if hdrs == None:
        hdrs = []

    if srcs == None:
        srcs = []

    if deps == None:
        deps = []

    if copts == None:
        copts = []

    if linkopts == None:
        linkopts = []

    return native.cc_library(
        name = name,
        visibility = visibility,
        defines = default_defines + defines,
        hdrs = hdr_list(boost_name, exclude_hdr) + hdrs,
        srcs = srcs_list(boost_name, exclude_src) + srcs,
        deps = deps,
        copts = default_copts + copts,
        includes = ["."],
        linkopts = linkopts,
        linkstatic = linkstatic,
        licenses = ["notice"],
    )

def boost_so_binary(
        name,
        boost_name = None,
        defines = [],
        srcs = None,
        deps = None,
        copts = None,
        exclude_src = [],
        visibility = ["//visibility:public"]):
    if boost_name == None:
        boost_name = name

    if srcs == None:
        srcs = []

    if deps == None:
        deps = []

    if copts == None:
        copts = []

    return native.cc_binary(
        name = name,
        visibility = visibility,
        srcs = hdr_list(boost_name) + srcs_list(boost_name, exclude_src) + srcs,
        deps = deps,
        copts = default_copts + copts,
        defines = default_defines + defines,
        linkshared = True,
        licenses = ["notice"],
    )

def boost_deps():
    if "bazel_skylib" not in native.existing_rules():
        http_archive(
            name = "bazel_skylib",
            sha256 = "1dde365491125a3db70731e25658dfdd3bc5dbdfd11b840b3e987ecf043c7ca0",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/0.9.0/bazel_skylib-0.9.0.tar.gz",
                "https://github.com/bazelbuild/bazel-skylib/releases/download/0.9.0/bazel_skylib-0.9.0.tar.gz",
            ],
        )

    if "net_zlib_zlib" not in native.existing_rules():
        http_archive(
            name = "net_zlib_zlib",
            build_file = "@com_github_nelhage_rules_boost//:BUILD.zlib",
            sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
            strip_prefix = "zlib-1.2.11",
            urls = [
                "https://mirror.bazel.build/zlib.net/zlib-1.2.11.tar.gz",
                "https://zlib.net/zlib-1.2.11.tar.gz",
            ],
        )

    if "org_bzip_bzip2" not in native.existing_rules():
        http_archive(
            name = "org_bzip_bzip2",
            build_file = "@com_github_nelhage_rules_boost//:BUILD.bzip2",
            sha256 = "a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd",
            strip_prefix = "bzip2-1.0.6",
            urls = [
                "https://mirror.bazel.build/www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz",
                "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz",
            ],
        )

    SOURCEFORGE_MIRRORS = ["phoenixnap", "newcontinuum", "cfhcable", "superb-sea2", "cytranet", "iweb", "gigenet", "ayera", "astuteinternet", "pilotfiber", "svwh"]

    if "org_lzma_lzma" not in native.existing_rules():
        http_archive(
            name = "org_lzma_lzma",
            build_file = "@com_github_nelhage_rules_boost//:BUILD.lzma",
            sha256 = "71928b357d0a09a12a4b4c5fafca8c31c19b0e7d3b8ebb19622e96f26dbf28cb",
            strip_prefix = "xz-5.2.3",
            urls = [
                "https://%s.dl.sourceforge.net/project/lzmautils/xz-5.2.3.tar.gz" % m
                for m in SOURCEFORGE_MIRRORS
            ],
        )

    if "com_github_facebook_zstd" not in native.existing_rules():
        http_archive(
            name = "com_github_facebook_zstd",
            urls = [
                "https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.gz",
            ],
            sha256 = "59ef70ebb757ffe74a7b3fe9c305e2ba3350021a918d168a046c6300aeea9315",
            build_file = "@com_github_nelhage_rules_boost//:BUILD.zstd",
            strip_prefix = "zstd-1.4.4",
        )

    if "boost" not in native.existing_rules():
        http_archive(
            name = "boost",
            build_file = "@com_github_nelhage_rules_boost//:BUILD.boost",
            sha256 = "d73a8da01e8bf8c7eda40b4c84915071a8c8a0df4a6734537ddde4a8580524ee",
            strip_prefix = "boost_1_71_0",
            urls = [
                "https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.bz2",
            ],
            patch_cmds = [ "rm -f doc/pdf/BUILD", ],
        )
