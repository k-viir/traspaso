# Convert the Metadata API Source

## Brief Explanation

After you retrieve the source from your org, you can complete the configuration of your project and convert the source to Salesforce DX project format.
The convert command ignores all files that start with a “dot,” such as .DS_Store. To exclude more files from the convert process, add a .forceignore file.

To indicate which package directory is the default, update the `sfdx-project.json` file.
Convert the metadata API source to Salesforce DX project format.

```sh
sfdx force:mdapi:convert --rootdir <retrieve dir name>
```

The `--rootdir` parameter is the name of the directory that contains the metadata source, that is, one of the package directories or subdirectories defined in the `sfdx-project.json` file.

If you don’t indicate an output directory with the `--outputdir` parameter, the converted source is stored in the default package directory indicated in the `sfdx-project.json` file. If the output directory is located outside of the project, you can indicate its location using an absolute path.

If there are two or more files with the same file name yet they contain different contents, the output directory contains duplicate files. Duplicate files can occur if you convert the same set of metadata more than once. The `mdapi:convert` process identifies these files with a .dup file extension. The source:push and source:pull commands ignore duplicate files, so you’ll want to resolve them. You have these options:
- Choose which file to keep, then delete the duplicate.
- Merge the files, then delete the other.

## Reference
https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_convert_mdapi.htm


