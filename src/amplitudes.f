!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2025 Guido Dhondt
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation(version 2);
!     
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!
!     You should have received a copy of the GNU General Public License
!     along with this program; if not, write to the Free Software
!     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
!
!     Changes:
!     2026/03/27: adding equation string variable amequ as subroutine parameter.
!     2026/03/26: Additional comments
!     2026/03/07: Introducing EQUATION parameter in syntax analysis
!
      subroutine amplitudes(inpc,textpart,amname,amequ,amta,namta,nam,
     &  nam_,namtot_,irstrt,istep,istat,n,iline,ipol,inl,ipoinp,inp,
     &  ipoinpc,namtot,ier)
!
!     reading the input deck: *AMPLITUDE
!
      implicit none
!
      logical user, equation
!
      character*1 inpc(*)
      character*80 amname(*)
      character*512 amequ(*)
      character*132 textpart(16)
!
      integer namta(3,*),nam,nam_,istep,istat,n,key,i,namtot,
     &  namtot_,irstrt(*),iline,ipol,inl,ipoinp(2,*),inp(3,*),ipos,
     &  ipoinpc(0:*),ier
!
      real*8 amta(2,*),x,y,shiftx,shifty
!
!     Initialize amplitude definition as non-user defined and not equation based:
      user=.false.
      equation=.false.
!
      shiftx=0.d0
      shifty=0.d0

!
c      if((istep.gt.0).and.(irstrt(1).ge.0)) then
c         write(*,*) '*ERROR reading *AMPLITUDE: *AMPLITUDE should be'
c         write(*,*) '  placed before all step definitions'
c         ier=1
c         return
c      endif
!
      nam=nam+1
      if(nam.gt.nam_) then
         write(*,*) '*ERROR reading *AMPLITUDE: increase nam_'
         ier=1
         return
      endif
      namta(3,nam)=nam
      amname(nam)='
     &                           '
!     Initialize equation string for amplitude calculation:
      amequ(nam)=''
!
      do i=2,n
         if(textpart(i)(1:5).eq.'NAME=') then
            amname(nam)=textpart(i)(6:85)
            if(textpart(i)(86:86).ne.' ') then
               write(*,*) '*ERROR reading *AMPLITUDE: amplitude'
               write(*,*) '      name is too long'
               write(*,*) '      (more than 80 characters)'
               write(*,*) '      amplitude name:',textpart(i)(1:132)
               ier=1
               return
            endif
         elseif(textpart(i)(1:14).eq.'TIME=TOTALTIME') then
            namta(3,nam)=-nam
         elseif(textpart(i)(1:4).eq.'USER') then
            namta(1,nam)=0
            namta(2,nam)=0
            user=.true.
         elseif(textpart(i)(1:18).eq.'DEFINITION=TABULAR') then
            cycle
         elseif(textpart(i)(1:14).eq.'VALUE=RELATIVE') then
            cycle
         elseif(textpart(i)(1:6).eq.'SHIFTX') then
               read(textpart(i)(8:27),'(f20.0)',iostat=istat) shiftx
               if(istat.gt.0) then
                  call inputerror(inpc,ipoinpc,iline,
     &                 "*AMPLITUDE%",ier)
                  return
               endif
         elseif(textpart(i)(1:6).eq.'SHIFTY') then
               read(textpart(i)(8:27),'(f20.0)',iostat=istat) shifty
               if(istat.gt.0) then
                  call inputerror(inpc,ipoinpc,iline,
     &                 "*AMPLITUDE%",ier)
                  return
               endif
         elseif(textpart(i)(1:8).eq.'EQUATION') then
            namta(1,nam)=0
            namta(2,nam)=0
            equation=.true.
         else
            write(*,*) 
     &        '*WARNING reading *AMPLITUDE: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(i)(1:index(textpart(i),' ')-1)
            call inputwarning(inpc,ipoinpc,iline,
     &"*AMPLITUDE%")
         endif
      enddo
!
      if(amname(nam).eq.'                                               
     &                                 ') then
         write(*,*) '*ERROR reading *AMPLITUDE: Amplitude has no name'
         call inputerror(inpc,ipoinpc,iline,
     &        "*AMPLITUDE%",ier)
         return
      endif
  
      if(equation.and.(shiftx.ne.0.d0.or.shifty.ne.0.d0)) then
        write(*,*) 
     &    '*ERROR reading *AMPLITUDE: Do not use SHIFTX or SHIFTY'
        write(*,*) 
     &    '  in equation based *AMPLITUDE definitions:'
        write(*,*) 
     &    '  Include their values to the equation string instead!'
        ier=1
        return
      endif 
!
      if((.not.user).and.(.not.equation)) then
         namta(1,nam)=namtot+1
      endif
!
!     read the amplitude times and values for the individual amplitude:
      do
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) exit
         do i=1,4
            if(textpart(2*i-1)(1:1).ne.' ') then  
               namtot=namtot+1
               if(namtot.gt.namtot_) then
!                 increase total number of allowed amplitude definitions:
                  write(*,*)
     &               '*ERROR reading *AMPLITUDE: increase namtot_'
                  ier=1
                  return
               endif
               if(equation) then
                 if(len(trim(amequ(nam))//trim(textpart(1))).ge.512)
     &             then
                   write(*,*)
     &               '*ERROR reading equation based *AMPLITUDE: ',
     &               'Equation string length must be less than ',
     &               '512 characters, ',
     &               'increase length of string array amequ!'
                   ier=1
                   return
                 end if
!                concatenate equation string with string of
!                next line in inp file:
                 amequ(nam) = trim(amequ(nam)) // trim(textpart(1))
               else
                 read(textpart(2*i-1),'(f20.0)',iostat=istat) x
                 if(istat.gt.0) then
                    call inputerror(inpc,ipoinpc,iline,
     &                   "*AMPLITUDE%",ier)
                    return
                 endif
                 read(textpart(2*i),'(f20.0)',iostat=istat) y
                 if(istat.gt.0) then
                   call inputerror(inpc,ipoinpc,iline,
     &                  "*AMPLITUDE%",ier)
                   return
                 endif
                 amta(1,namtot)=x+shiftx
                 amta(2,namtot)=y+shifty
                 namta(2,nam)=namtot
               endif
            else
               exit
            endif
         enddo
      enddo
!
!     namta(1,i) = location of first (time, i th amplitude name) pair in field amta
!     namta(2,i) = location of last (time, i th amplitude name) pair in field amta
      if(namta(1,nam).gt.namta(2,nam)) then
         ipos=index(amname(nam),' ')
         write(*,*) 
     &      '*WARNING reading *AMPLITUDE: *AMPLITUDE definition ',
     &       amname(nam)(1:ipos-1) 
         write(*,*) '         has no data points'
         nam=nam-1
c      else
c         call reorderampl(amname,namta,nam)
      endif
!
      return
      end

