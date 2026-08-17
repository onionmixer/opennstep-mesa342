/*
 * Installer derives architecture choices from Mach-O payload files, not from
 * Mach-O object members within static archives. Mesa is delivered as static
 * archives, so this i386-only marker makes the package architecture explicit.
 * It is not a Mesa API or a user-facing program.
 */
int
main(void)
{
    return 0;
}
