using Avalonia.Controls;

namespace Wox.Views;

public partial class CoreQueryView : UserControl
{
    public CoreQueryView()
    {
        InitializeComponent();
        QueryTextBox.Focus();
    }
}