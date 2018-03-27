// replaces all occurances of 'find' with 'replace' in str
string replace(string str, string find_substr, string replace_substr) {
	list segments = llParseStringKeepNulls(src, [find_substr], []);
	string new_string = llDumpList2String(segments, replace_substr);
	return new_string;
}

