#!/usr/bin/perl -w -- 
#
# generated by wxGlade 1.1.0 on Mon Jan  6 18:55:44 2025
#
# To get wxPerl visit http://www.wxperl.it
#

$|++; # need autoflush

use Wx qw[:allclasses];
use strict;
use threads; # used for non-blocking GUI responsiveness

# begin wxGlade: dependencies
# end wxGlade

# begin wxGlade: extracode
# end wxGlade

package MyFrame;

use Wx qw[:everything];
use base qw(Wx::Frame);
use strict;

sub new {
    my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
    $parent = undef              unless defined $parent;
    $id     = -1                 unless defined $id;
    $title  = ""                 unless defined $title;
    $pos    = wxDefaultPosition  unless defined $pos;
    $size   = wxDefaultSize      unless defined $size;
    $name   = ""                 unless defined $name;

    # begin wxGlade: MyFrame::new
    $style = wxDEFAULT_FRAME_STYLE
        unless defined $style;

    $self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
    $self->SetSize(Wx::Size->new(364, 169));
    $self->SetTitle("Perl +OpenMP Demo");
    
    

    # Menu Bar

    $self->{frame_menubar} = Wx::MenuBar->new();
    my $wxglade_tmp_menu;
    $wxglade_tmp_menu = Wx::Menu->new();
    $wxglade_tmp_menu->Append(wxID_ANY, "About", "");
    $self->{frame_menubar}->Append($wxglade_tmp_menu, "Help");
    $self->SetMenuBar($self->{frame_menubar});
    
    # Menu Bar end

    
    $self->{panel_1} = Wx::Panel->new($self, wxID_ANY);
    
    $self->{sizer_1} = Wx::FlexGridSizer->new(2, 3, 0, 0);
    
    $self->{grid_sizer_1} = Wx::StaticBoxSizer->new(Wx::StaticBox->new($self->{panel_1}, wxID_ANY, "OpenMP Threads"), wxVERTICAL);
    $self->{sizer_1}->Add($self->{grid_sizer_1}, 1, wxALL|wxEXPAND, 0);
    
    $self->{spin_ctrl_1} = Wx::SpinCtrl->new($self->{grid_sizer_1}->GetStaticBox(), wxID_ANY, "0", wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 100, 0);
    $self->{spin_ctrl_1}->SetMinSize(Wx::Size->new(100, 23));
    $self->{grid_sizer_1}->Add($self->{spin_ctrl_1}, 0, 0, 0);
    
    $self->{grid_sizer_1}->Add(20, 20, 0, wxEXPAND, 0);
    
    $self->{sizer_2} = Wx::FlexGridSizer->new(1, 2, 0, 0);
    $self->{grid_sizer_1}->Add($self->{sizer_2}, 1, wxEXPAND, 0);
    
    $self->{checkbox_1} = Wx::CheckBox->new($self->{grid_sizer_1}->GetStaticBox(), wxID_ANY, "loop");
    $self->{checkbox_1}->SetValue(1);
    $self->{sizer_2}->Add($self->{checkbox_1}, 0, wxALIGN_CENTER, 0);
    
    $self->{button_1} = Wx::Button->new($self->{grid_sizer_1}->GetStaticBox(), wxID_ANY, "Start");
    $self->{sizer_2}->Add($self->{button_1}, 0, wxALIGN_RIGHT, 0);
    
    $self->{sizer_1}->Add(60, 20, 0, wxEXPAND, 0);
    
    my $bitmap_1 = Wx::StaticBitmap->new($self->{panel_1}, wxID_ANY, Wx::Bitmap->new("./project-logo.jpg", wxBITMAP_TYPE_ANY));
    $self->{sizer_1}->Add($bitmap_1, 0, wxALIGN_CENTER_VERTICAL, 0);
    
    $self->{sizer_2}->AddGrowableRow(0);
    
    $self->{panel_1}->SetSizer($self->{sizer_1});
    
    $self->Layout();
    Wx::Event::EVT_BUTTON($self, $self->{button_1}->GetId, $self->can('makeOpenMPBusy'));

    # end wxGlade
    $self->{spin_ctrl_1}->SetValue(8);
    return $self;

}

sub makeOpenMPBusy {
    my ($self, $event) = @_;
    # wxGlade: MyFrame::makeOpenMPBusy <event_handler>
    # end wxGlade
    $self->{button_1}->SetLabel("running...");
    $self->{button_1}->Enable(0);
    use OpenMP;
    use Inline (
      C    => <<EOC,
/* C function parallelized with OpenMP */
int _check_num_threads() {
  int ret = 0;
    
  PerlOMP_GETENV_BASIC
   
  #pragma omp parallel
  {
    #pragma omp single
    ret = omp_get_num_threads();
  }
 
  return ret;
}

#define M 2000  // Size of the matrix (increase M for more stress)
#define N 2000  // Size of the matrix (increase N for more stress)
#define P 2000  // Size of the matrix (increase P for more stress)

void matrix_multiply(double *A, double *B, double *C, int n, int m, int p) {
    #pragma omp parallel for collapse(2)
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < p; j++) {
            C[i * p + j] = 0;
            for (int k = 0; k < m; k++) {
                C[i * p + j] += A[i * m + k] * B[k * p + j];
            }
        }
    }
}

int dowork() {
    // Allocate matrices
    double *A = (double *)malloc(N * M * sizeof(double));
    double *B = (double *)malloc(M * P * sizeof(double));
    double *C = (double *)malloc(N * P * sizeof(double));

    // Initialize matrices with values
    for (int i = 0; i < N * M; i++) {
        A[i] = i % 100;  // Some arbitrary values
    }
    for (int i = 0; i < M * P; i++) {
        B[i] = (i % 100) + 1;  // Some arbitrary values
    }

    // Perform matrix multiplication
    matrix_multiply(A, B, C, N, M, P);

    // Clean up
    free(A);
    free(B);
    free(C);
    return 0;
}

EOC
      with => qw/OpenMP::Simple/,
    );
    my $omp = OpenMP->new; # place in $self ...

    $self->{worker_thread} = threads->create(
      sub {
         while ($self->{checkbox_1}->IsChecked()) {
           my $want_num_threads = $self->{spin_ctrl_1}->GetValue();
           $omp->env->omp_num_threads($want_num_threads);
           my $got_num_threads = _check_num_threads();
           printf "INFO: %0d threads spawned in the OpenMP runtime, expecting %0d\n",
                  $got_num_threads, $want_num_threads;
           printf "INFO: about to do bunch of work ";
           print dowork();
           printf "... done ...\n";
         }
         $self->{button_1}->SetLabel("Start");
         $self->{button_1}->Enable(1);
      },
      $self
    );
}


sub updateSpinner {
    my ($self, $event) = @_;
    # wxGlade: MyFrame::updateSpinner <event_handler>
    # end wxGlade
    $self->{spin_ctrl_1}->SetValue($self->{slider_1}->GetValue());
}

# end of class MyFrame

1;

package MyApp;

use base qw(Wx::App);
use strict;

sub OnInit {
    my( $self ) = shift;

    Wx::InitAllImageHandlers();

    my $frame = MyFrame->new();

    $self->SetTopWindow($frame);
    $frame->Show(1);

    return 1;
}
# end of class MyApp

package main;

unless(caller){
    my $app = MyApp->new();
    $app->MainLoop();
}
