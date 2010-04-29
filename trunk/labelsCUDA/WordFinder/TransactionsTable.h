class TrunsactionsTable
{
public:
	Transition*  Table;
	int Size;
	int ElementSize;

	TrunsactionsTable()
	{
		Table = NULL;
		Size = 0;
		ElementSize = sizeof(Transition) * 255;
	}

	~TrunsactionsTable()
	{
		if (Table != NULL)
		{
			delete Table;
		}
	}
};