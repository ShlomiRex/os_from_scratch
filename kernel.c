void main() {
	// Print OK on the second line
	*(char*)0xb80A0 = 'O';
	*(char*)0xb80A2 = 'K';
	return;
}