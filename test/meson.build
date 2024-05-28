# Test Build Definition

# TODO: add in unity? support, everything uses cmocka right now
# Consider unity support for C, gTest support for c++
# look into FFF for mocking

# PROJECT_test_files = ['test/test_file.c', 'test/test_work.c']
test_files = files('main.c')
files_to_lint += test_files
#######################################################################################################
## Create executables and Register tests with meson.                                                  #
##                                                                                                    #
## Tests are created in the following ways:                                                           #
## On the first pass, we analyze all source files <src_file>.c                                        #
## For a test runner to be generated, test files must have the form test_<src_file>.c                 #
## Additional files can be linked into the test in the form <prefix><src_file><postfix>.c             #
##                                                                                                    #
## On the second pass, we look for orphaned test files, of the form test_<file>.c                     #
## If there's no corresponding source file which contains <file>, we'll make a test runner and test.  #
##                                                                                                    #
## The general philosophy here is to unit test singular source files, and mock all dependencies.      #
## "Needing" access to other source files is probably code smell, will have to be configured manually #
## if you really want it                                                                              #
##
## Finally, this is very specialized to work with Unity's test runner generator. 
## Obviously, you can run all the tests out of one main file, but doing it this way allows you to 
## run tests individually from meson as needed.
#######################################################################################################

# TODO: source files and includes
# TODO: json/junit output

# Initialize a list to store test executables
test_exes = []

# First pass: match source files to test files, create test runners and bind to meson
# Iterate over source files
foreach src_file : src_files
    
    # split off the folders from the filepath, filename in last index
    # then split off file type and store the filename without extension
    # e.g. asdf/fdsa/test_src.c
    # split at / -> ['asdf', 'fdsa', 'test_src.c']
    # split at '.' -> ['test_src', 'c']
    substring = (src_file.split('/')[-1].split('.'))[0].to_lower()
    
    matched_files = []
    main_test_file = ''
    foreach test_file : test_files
        if (test_file.to_lower()).contains(substring)
            matched_files += test_file
            if (test_file.to_lower()).contains('test')
                main_test_file = test_file
            endif
        endif
    endforeach 
    
    test_exe = executable(
        substring,
        sources: [
            src_file, 
            matched_files,
            runner_gen.process(test_file)
        ],
        include_directories: [inc],
        dependencies: [unity_dep, fff_dep],
        native: true,
    )
    
    # Register the test with Meson
    test(substring, test_exe)
    
    # Append the test executable to the list
    test_exes += [test_exe]

endforeach


# Second pass: look for orphan test files that don't have a matching source file
foreach test_file : test_files
    # look for files that have test in the name
    if test_file.to_lower().contains('test')

        # asdf/fdaa/test_file.c
        # split at test_ -> ['asdf/fdaa/test', 'file.c']
        # split at '.' -> ['file', 'c']
        substring = test_file.to_lower().split('test_')[1].split('.')[0]
        
        src_found = false
        # search through all source files, create test if we CANT find a match
        foreach src_file : src_files
            if src_file.to_lower().contains(substring)
                src_found = true
                break
            endif
        endforeach

        # if a file starts with test_, and doesn't have a corresponding src file, make the test and testrunner
        if src_found == false
            test_exe = executable(
                substring,
                sources: [                    
                    test_file,
                    runner_gen.process(test_file)
                ],
                include_directories: [inc],
                dependencies: [unity_dep, fff_dep],
                native: true,
            )
    
            # Register the test with Meson
            test(substr, test_exe)
            
            # Append the test executable to the list
            test_exes += [test_exe]
        endif
    endif
endforeach



# #######################
# # Test Compiler Flags #
# #######################

# test_suite_compiler_flags = native_c_compiler.get_supported_arguments(
# 	'-Wno-unused-parameter',
# )

# ###############
# # Test Target #
# ###############

# ## Subproject Example
# PROJECT_tests = executable('PROJECT_tests',
# 	PROJECT_test_files,
# 	# dependencies: [cmocka_native_dep, libc_hosted_native_dep],
# 	dependencies: [PROJECT_test_runner_dep,],
# 	link_args: native_map_file.format(meson.current_build_dir() + '/libc_test'),
# 	c_args: test_suite_compiler_flags,
# 	native: true
# )

################################
# Cross Compilation "Test" App #
################################
# This application is used to confirm linking behavior, primarily for cross builds

# if meson.is_cross_build()

# 	host_objcopy = find_program(meson.get_external_property('objcopy'),
# 		required: false, disabler: true)

# 	if host_objcopy.found() == false
# 		message('Specified objcopy not found, .hex and .bin conversion is disabled.')
# 	endif

# 	sample_app = executable('sample_app',
# 		'app/main.c',
# 		dependencies: libc_dep,
# 		link_args: [
# 			linker_script_flags,
# 			map_file.format(meson.current_build_dir()+'/sample_app'),
# 		],
# 		link_depends: linker_script_deps,
# 		native: false
# 	)

# 	sample_app_hex = custom_target('sample_app.hex',
# 		input: sample_app,
# 		output: 'sample_app.hex',
# 		command: [host_objcopy, '-O', 'ihex', '@INPUT@', '@OUTPUT@'],
# 		build_by_default: true
# 	)

# 	sample_app_bin = custom_target('sample_app.bin',
# 		input: sample_app,
# 		output: 'sample_app.bin',
# 		command: [host_objcopy, '-O', 'binary', '@INPUT@', '@OUTPUT@'],
# 		build_by_default: true
# 	)
# endif

#############################
# Register Tests with Meson #
#############################

# test_output_dir = 'CMOCKA_XML_FILE=' + meson.project_build_root() + '/test/%g.xml'

# test('libc_tests',
# 	libc_tests,
# 	env: [test_output_dir])

# run_target('libc-tests',
# 	command: [libc_tests]
# )

# run_target('libc-tests-xml',
# 	command: [
# 		meson.project_source_root() + '/tools/exec_program_with_env.sh',
# 		libc_tests,
# 		test_output_dir
# 	],
# )
