/*

�t�@�C�����o�̓��C�u�����̃e�X�g
(fopen/fgetc/fclose)

�g����:
sltype �t�@�C����

*/
ORG	$100

main ()
var	c;
{
	if (fopen(0, $81, 0) != 0) {
		return;
	}
	while (1) {
		c = fgetc(0);
		if (c > $ff OR c == $1a) {
			exit;
		}
		^DE = c;
		^BC = 2;					//�R���\�[���o��(_CONOUT)
		CALL(5);
	}
	fclose(0);
}
