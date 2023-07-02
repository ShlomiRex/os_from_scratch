extern "C" void main() {
	// Print OK on the next line
	*(char*)0xb8140 = 'O';
	*(char*)0xb8142 = 'K';
}