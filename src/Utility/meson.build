utility_inc = [
	include_directories('.'),	
]

# If you have a utility with a source file, add it with a subdir() command
# or add it to the `utility_sources` list above
# subdir('dir')
utility_sources = [files('example.c')]

files_to_lint += [
	utility_sources,
	utility_inc,
]

libutil = static_library('util',
	utility_sources,
	include_directories: utility_inc,
	install: false,
	build_by_default: false
)

libutil_native = static_library('util_native',
	utility_sources,
	include_directories: utility_inc,
	install: false,
	build_by_default: false,
	native: true,
)

utility_dep = declare_dependency(
	include_directories: utility_inc,
	link_with: libutil,
)

utility_native_dep = declare_dependency(
	include_directories: utility_inc,
	link_with: libutil_native,
)
