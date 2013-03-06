module BigRationals

export BigRational

import
    Base.(*),
    Base.+,
    Base.-,
    Base./,
    Base.<,
    Base.<<,
    Base.>>,
    Base.<=,
    Base.==,
    Base.>,
    Base.>=,
    Base.^,
    Base.(~),
    Base.(&),
    Base.(|),
    Base.($),
    Base.binomial,
    Base.ceil,
    Base.cmp,
    Base.complex,
    Base.convert,
    Base.div,
    Base.den,
    Base.factorial,
    Base.fld,
    Base.floor,
    Base.gcd,
    Base.gcdx,
    Base.isinf,
    Base.isnan,
    Base.lcm,
    Base.mod,
    Base.ndigits,
    Base.num,
    Base.promote_rule,
    Base.rem,
    Base.show,
    Base.showcompact,
    Base.sqrt,
    Base.string,
    Base.trunc

type BigRational <: Real
    mpq::Vector{Int32}
    function BigRational()
        z = Array(Int32, 5)
        ccall((:__gmpq_init,:libgmp), Void, (Ptr{Void},), z)
        b = new(z)
        finalizer(b, BigRational_clear)
        return b
    end
end

function BigRational(x::BigRational)
    z = BigRational()
    ccall((:__gmpq_set, :libgmp), Void, (Ptr{Void}, Ptr{Void}), z.mpq, x.mpq)
    return z
end

function BigRational(x::String)
    z = BigRational()
    err = ccall((:__gmpq_set_str, :libgmp), Int32, (Ptr{Void}, Ptr{Uint8}, Int32), z.mpq, bytestring(x), 0)
    if err != 0; error("Invalid input"); end
    ccall((:__gmpq_canonicalize, :libgmp), Void, (Ptr{Void},), z.mpq)
    return z
end

function BigRational(x::Uint, y::Uint)
    z = BigRational()
    ccall((:__gmpq_set_ui, :libgmp), Void, (Ptr{Void}, Uint, Uint), z.mpq, x, y)
    ccall((:__gmpq_canonicalize, :libgmp), Void, (Ptr{Void},), z.mpq)
    return z
end

function BigRational(x::Int, y::Int)
    z = BigRational()
    ccall((:__gmpq_set_si, :libgmp), Void, (Ptr{Void}, Int, Int), z.mpq, x, y)
    ccall((:__gmpq_canonicalize, :libgmp), Void, (Ptr{Void},), z.mpq)
    return z
end

BigRational(r::Rational) = BigRational(num(r), den(r))

function BigRational(x::BigInt)
    z = BigRational()
    ccall((:__gmpq_set_z, :libgmp), Void, (Ptr{Void}, Ptr{Void}), z.mpq, x.mpz)
    return z
end

for (fJ, fC) in ((:+,:add), (:-,:sub), (:*,:mul), (:/,:div))
    @eval begin 
        function ($fJ)(x::BigRational, y::BigRational)
            z = BigRational()
            ccall(($(string(:__gmpq_,fC)),:libgmp), Void, (Ptr{Void}, Ptr{Void}, Ptr{Void}), z.mpq, x.mpq, y.mpq)
            return z
        end
    end
end

string(x::BigRational) = string(num(x), "//", den(x))

show(io::IO, b::BigRational) = print(io, string(b))
showcompact(io::IO, b::BigRational) = print(io, string(b))

function BigRational_clear(x::BigRational)
    ccall((:__gmpq_clear, :libgmp), Void, (Ptr{Void},), x.mpq)
end

function num(x::BigRational)
    z = BigInt()
    ccall((:__gmpq_get_num, :libgmp), Void, (Ptr{Void}, Ptr{Void}), z.mpz, x.mpq)
    return z
end

function den(x::BigRational)
    z = BigInt()
    ccall((:__gmpq_get_den, :libgmp), Void, (Ptr{Void}, Ptr{Void}), z.mpz, x.mpq)
    return z
end

ndigits(x::BigRational) = ndigits(num(x)) + ndigits(den(x)) + 2

end
